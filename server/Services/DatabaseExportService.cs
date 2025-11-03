using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Logging;

namespace Placesoft.AppVentas.Server.Services;

/// <summary>
/// Servicio encargado de construir los archivos SQLite que consume la aplicación
/// móvil. Copia datos desde la base transaccional hacia archivos temporales y
/// devuelve los bytes listos para ser descargados por la API.
/// </summary>
public sealed class DatabaseExportService
{
    private readonly Func<CancellationToken, Task<DbConnection>> _connectionFactory;
    private readonly ILogger<DatabaseExportService> _logger;
    private readonly string _workingDirectory;

    public DatabaseExportService(
        Func<CancellationToken, Task<DbConnection>> connectionFactory,
        ILogger<DatabaseExportService> logger,
        string? workingDirectory = null)
    {
        _connectionFactory = connectionFactory ?? throw new ArgumentNullException(nameof(connectionFactory));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _workingDirectory = string.IsNullOrWhiteSpace(workingDirectory)
            ? Path.Combine(Path.GetTempPath(), "placesoft", "exports")
            : workingDirectory;
    }

    /// <summary>
    /// Genera el archivo <c>clientes.db</c> consumido por la aplicación Android.
    /// </summary>
    public Task<DatabaseExportResult> ExportClientesAsync(
        string prefix,
        CancellationToken cancellationToken = default)
    {
        var normalizedPrefix = NormalizePrefix(prefix);
        return ExportDatabaseAsync(
            databaseName: "clientes",
            prefix: normalizedPrefix,
            expectedTables: new[] { "mae_clientes", "mae_clientes_destinos" },
            tableBuilders: new[]
            {
                TableExportSpec.Create(
                    tableName: "mae_clientes",
                    selectSql: "SELECT * FROM mae_clientes WHERE prefijo = @prefijo",
                    configureCommand: static (command, prefijo) =>
                    {
                        var parameter = command.CreateParameter();
                        parameter.ParameterName = "@prefijo";
                        parameter.Value = prefijo;
                        command.Parameters.Add(parameter);
                    }),
                TableExportSpec.Create(
                    tableName: "mae_clientes_destinos",
                    selectSql: "SELECT * FROM mae_clientes_destinos WHERE prefijo = @prefijo",
                    configureCommand: static (command, prefijo) =>
                    {
                        var parameter = command.CreateParameter();
                        parameter.ParameterName = "@prefijo";
                        parameter.Value = prefijo;
                        command.Parameters.Add(parameter);
                    }),
            },
            cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Genera el archivo <c>productos.db</c>. Se utiliza como referencia para
    /// garantizar que ambos exportadores compartan el mismo flujo.
    /// </summary>
    public Task<DatabaseExportResult> ExportProductosAsync(
        string prefix,
        CancellationToken cancellationToken = default)
    {
        var normalizedPrefix = NormalizePrefix(prefix);
        return ExportDatabaseAsync(
            databaseName: "productos",
            prefix: normalizedPrefix,
            expectedTables: new[] { "mae_articulos_00", "mae_articulos_precios_00" },
            tableBuilders: new[]
            {
                TableExportSpec.Create(
                    tableName: "mae_articulos_00",
                    selectSql: "SELECT * FROM mae_articulos_00 WHERE prefijo = @prefijo",
                    configureCommand: static (command, prefijo) =>
                    {
                        var parameter = command.CreateParameter();
                        parameter.ParameterName = "@prefijo";
                        parameter.Value = prefijo;
                        command.Parameters.Add(parameter);
                    }),
                TableExportSpec.Create(
                    tableName: "mae_articulos_precios_00",
                    selectSql: "SELECT * FROM mae_articulos_precios_00 WHERE prefijo = @prefijo",
                    configureCommand: static (command, prefijo) =>
                    {
                        var parameter = command.CreateParameter();
                        parameter.ParameterName = "@prefijo";
                        parameter.Value = prefijo;
                        command.Parameters.Add(parameter);
                    }),
            },
            cancellationToken: cancellationToken);
    }

    private async Task<DatabaseExportResult> ExportDatabaseAsync(
        string databaseName,
        string prefix,
        IReadOnlyCollection<string> expectedTables,
        IReadOnlyCollection<TableExportSpec> tableBuilders,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(databaseName))
        {
            throw new ArgumentException("Database name is required", nameof(databaseName));
        }

        if (expectedTables.Count == 0)
        {
            throw new ArgumentException("At least one table must be exported", nameof(expectedTables));
        }

        if (tableBuilders.Count == 0)
        {
            throw new ArgumentException("No export builders provided", nameof(tableBuilders));
        }

        Directory.CreateDirectory(_workingDirectory);
        var fileName = $"{prefix}_{databaseName}.db";
        var destinationPath = Path.Combine(_workingDirectory, fileName);
        var tempPath = destinationPath + ".tmp";

        if (File.Exists(tempPath))
        {
            File.Delete(tempPath);
        }

        await using var sqlite = new SqliteConnection(new SqliteConnectionStringBuilder
        {
            DataSource = tempPath,
            Mode = SqliteOpenMode.ReadWriteCreate,
        }.ToString());

        await sqlite.OpenAsync(cancellationToken);
        await sqlite.ExecuteAsync("PRAGMA journal_mode=WAL;", cancellationToken);
        await sqlite.ExecuteAsync("PRAGMA synchronous=OFF;", cancellationToken);

        await using var connection = await _connectionFactory(cancellationToken);
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }
        foreach (var spec in tableBuilders)
        {
            await ExportTableAsync(connection, sqlite, spec, prefix, cancellationToken);
        }

        await sqlite.CloseAsync();

        ValidateDatabaseFile(tempPath, expectedTables);
        File.Move(tempPath, destinationPath, overwrite: true);
        var bytes = await File.ReadAllBytesAsync(destinationPath, cancellationToken);

        _logger.LogInformation(
            "Base {Database} exportada correctamente para el prefijo {Prefix} en {Path} ({Bytes} bytes)",
            databaseName,
            prefix,
            destinationPath,
            bytes.LongLength);

        return new DatabaseExportResult(destinationPath, bytes);
    }

    private static async Task ExportTableAsync(
        DbConnection source,
        SqliteConnection destination,
        TableExportSpec spec,
        string prefix,
        CancellationToken cancellationToken)
    {
        await using var select = source.CreateCommand();
        select.CommandText = spec.SelectSql;
        spec.ConfigureCommand?.Invoke(select, prefix);

        await using var reader = await select.ExecuteReaderAsync(cancellationToken);
        var schema = reader.GetColumnSchema();
        await CreateTableAsync(destination, spec.TableName, schema, cancellationToken);
        await CopyRowsAsync(destination, spec.TableName, schema, reader, cancellationToken);
    }

    private static async Task CreateTableAsync(
        SqliteConnection sqlite,
        string tableName,
        IReadOnlyList<DbColumn> columns,
        CancellationToken cancellationToken)
    {
        if (columns.Count == 0)
        {
            throw new InvalidOperationException($"No se recibieron columnas para la tabla {tableName}");
        }

        var commandText = new StringBuilder();
        commandText.Append("CREATE TABLE IF NOT EXISTS \"")
            .Append(tableName)
            .Append("\" (");

        for (var index = 0; index < columns.Count; index++)
        {
            var column = columns[index];
            var type = MapSqliteType(column);
            commandText.Append('\"')
                .Append(column.ColumnName)
                .Append("\" ")
                .Append(type);

            if (index < columns.Count - 1)
            {
                commandText.Append(", ");
            }
        }

        commandText.Append(')');

        await using var create = sqlite.CreateCommand();
        create.CommandText = commandText.ToString();
        await create.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task CopyRowsAsync(
        SqliteConnection sqlite,
        string tableName,
        IReadOnlyList<DbColumn> columns,
        DbDataReader reader,
        CancellationToken cancellationToken)
    {
        var columnNames = columns.Select(c => $"\"{c.ColumnName}\"").ToArray();
        var parameterNames = columns.Select((_, index) => $"@p{index}").ToArray();

        var insertSql = $"INSERT INTO \"{tableName}\" ({string.Join(", ", columnNames)}) VALUES ({string.Join(", ", parameterNames)})";

        await using var transaction = await sqlite.BeginTransactionAsync(cancellationToken);
        await using var insert = sqlite.CreateCommand();
        insert.CommandText = insertSql;
        insert.Transaction = transaction;

        foreach (var parameterName in parameterNames)
        {
            insert.Parameters.Add(new SqliteParameter(parameterName, null));
        }

        while (await reader.ReadAsync(cancellationToken))
        {
            for (var i = 0; i < columns.Count; i++)
            {
                insert.Parameters[i].Value = reader.IsDBNull(i) ? DBNull.Value : reader.GetValue(i);
            }

            await insert.ExecuteNonQueryAsync(cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
    }

    private static string MapSqliteType(DbColumn column)
    {
        if (column.DataType == typeof(long) ||
            column.DataType == typeof(int) ||
            column.DataType == typeof(short) ||
            column.DataType == typeof(byte) ||
            string.Equals(column.DataTypeName, "int", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(column.DataTypeName, "integer", StringComparison.OrdinalIgnoreCase))
        {
            return "INTEGER";
        }

        if (column.DataType == typeof(double) ||
            column.DataType == typeof(float) ||
            column.DataType == typeof(decimal) ||
            string.Equals(column.DataTypeName, "numeric", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(column.DataTypeName, "decimal", StringComparison.OrdinalIgnoreCase))
        {
            return "REAL";
        }

        if (column.DataType == typeof(byte[]) ||
            string.Equals(column.DataTypeName, "blob", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(column.DataTypeName, "binary", StringComparison.OrdinalIgnoreCase))
        {
            return "BLOB";
        }

        return "TEXT";
    }

    private static void ValidateDatabaseFile(string path, IEnumerable<string> expectedTables)
    {
        if (!File.Exists(path))
        {
            throw new InvalidOperationException($"No se generó el archivo en {path}");
        }

        var fileInfo = new FileInfo(path);
        if (fileInfo.Length <= 0)
        {
            throw new InvalidOperationException($"El archivo {path} está vacío");
        }

        using var connection = new SqliteConnection(new SqliteConnectionStringBuilder
        {
            DataSource = path,
            Mode = SqliteOpenMode.ReadOnly,
        }.ToString());

        connection.Open();

        foreach (var table in expectedTables)
        {
            using var command = connection.CreateCommand();
            command.CommandText = "SELECT name FROM sqlite_master WHERE type = 'table' AND name = $name";
            command.Parameters.AddWithValue("$name", table);
            var result = command.ExecuteScalar();
            if (result is null)
            {
                throw new InvalidOperationException($"La tabla {table} no existe en {path}");
            }
        }
    }

    private static string NormalizePrefix(string prefix)
    {
        if (string.IsNullOrWhiteSpace(prefix))
        {
            throw new ArgumentException("El prefijo es obligatorio", nameof(prefix));
        }

        return prefix.Trim().ToLowerInvariant();
    }

    private sealed record TableExportSpec(
        string TableName,
        string SelectSql,
        Action<DbCommand, string>? ConfigureCommand)
    {
        public static TableExportSpec Create(
            string tableName,
            string selectSql,
            Action<DbCommand, string>? configureCommand = null)
            => new(tableName, selectSql, configureCommand);
    }
}

public sealed record DatabaseExportResult(string Path, IReadOnlyList<byte> Bytes)
{
    public FileStream CreateReadStream() => File.OpenRead(Path);
}

internal static class SqliteConnectionExtensions
{
    public static async Task ExecuteAsync(this SqliteConnection connection, string sql, CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}

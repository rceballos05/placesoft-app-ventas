import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class _LocalDbEntry {
  const _LocalDbEntry({required this.name, required this.sizeKb});

  final String name;
  final double sizeKb;
}

Future<void> mostrarInfoBasesLocales(BuildContext context) async {
  final Directory documentsDirectory = await getApplicationDocumentsDirectory();
  final List<_LocalDbEntry> bases = [];

  await for (final FileSystemEntity entity
      in documentsDirectory.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.toLowerCase().endsWith('.db')) {
      continue;
    }

    final int sizeBytes = await entity.length();
    final double sizeKb = sizeBytes / 1024;
    final List<String> segments = entity.path.split(Platform.pathSeparator);
    final String name = segments.isNotEmpty ? segments.last : entity.path;

    bases.add(_LocalDbEntry(name: name, sizeKb: sizeKb));
  }

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      if (bases.isEmpty) {
        return AlertDialog(
          title: const Text('Bases de datos locales'),
          content: const Text(
            'No se encontraron bases locales en el dispositivo.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      }

      return AlertDialog(
        title: const Text('Bases de datos locales'),
        content: SingleChildScrollView(
          child: ListBody(
            children: bases
                .map(
                  (base) => Text(
                    '${base.name} - ${base.sizeKb.toStringAsFixed(2)} KB',
                  ),
                )
                .toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

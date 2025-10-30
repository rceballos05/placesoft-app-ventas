import 'dart:developer' as developer;

import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/db/rollo_db.dart';
import 'package:aplicacion_ventas/db/settings_db.dart';
import 'package:aplicacion_ventas/db/ventas_db.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/models/local_venta_cabeza.dart';
import 'package:aplicacion_ventas/models/local_venta_detalle.dart';
import 'package:aplicacion_ventas/models/local_venta_observacion.dart';
import 'package:aplicacion_ventas/models/log_track.dart';
import 'package:aplicacion_ventas/models/rollo_observacion.dart';
import 'package:aplicacion_ventas/models/rollo_terreno.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a cart line combining a rollo record with its optional observation.
class CartLine {
  const CartLine({required this.rollo, this.observacion});

  final RolloTerreno rollo;
  final RolloObservacion? observacion;

  CartLine copyWith({RolloTerreno? rollo, RolloObservacion? observacion}) => CartLine(
        rollo: rollo ?? this.rollo,
        observacion: observacion ?? this.observacion,
      );
}

/// State consumed by the cart UI.
class CartState {
  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<CartLine> items;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty;

  double get total => items.fold<double>(
        0,
        (previousValue, element) => previousValue + (element.rollo.totalLinea ?? 0),
      );

  CartState copyWith({
    List<CartLine>? items,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool resetError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod notifier that orchestrates cart operations and persists the data in
/// the local SQLite databases.
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._ref) : super(const CartState()) {
    _loadCart();
  }

  final Ref _ref;

  Future<void> _loadCart() async {
    state = state.copyWith(isLoading: true, resetError: true);
    try {
      final rollos = await DBRolloTerreno.getAll();
      final observaciones = await DBRolloObservaciones.getAll();
      final observationMap = {
        for (final obs in observaciones)
          if (obs.codigo != null) obs.codigo!: obs,
      };
      final lines = rollos
          .map((rollo) => CartLine(
                rollo: rollo,
                observacion: rollo.artCodigo != null ? observationMap[rollo.artCodigo!] : null,
              ))
          .toList();
      state = state.copyWith(items: lines, isLoading: false, resetError: true);
    } catch (error, stackTrace) {
      await _logError('loadCart', error, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el carrito.',
      );
    }
  }

  Future<void> addProductFromCatalog(Product product, {int quantity = 1, String? observation}) async {
    final now = DateTime.now();
    final loginState = _ref.read(loginControllerProvider);
    final user = loginState.user;
    final rut = user?.rut ?? '';
    final local = user?.prefijo ?? '00';
    final caja = user?.caja ?? '00';
    final formattedDate = _formatDate(now);
    final formattedTime = _formatTime(now);

    final rollo = RolloTerreno(
      local: local,
      cajaDoc: caja,
      rutCajero: rut,
      artCantidad: quantity.toDouble(),
      artCodigo: product.code,
      artDescripcion: product.description,
      artDescuento: product.discount,
      artPrecio: product.price,
      totalLinea: product.price * quantity,
      rutVendedor: rut,
      fechaTransaccion: formattedDate,
      horaTransaccion: formattedTime,
      tipoVenta: 'NPE',
      codImpuesto: '0000',
      porceImpuesto: 0,
    );

    await addProduct(rollo, observationText: observation);
  }

  Future<void> addProduct(RolloTerreno item, {String? observationText}) async {
    state = state.copyWith(isSaving: true, resetError: true);
    try {
      final existingIndex = state.items.indexWhere(
        (line) => line.rollo.artCodigo != null && line.rollo.artCodigo == item.artCodigo,
      );
      if (existingIndex >= 0) {
        final existing = state.items[existingIndex];
        final existingQty = existing.rollo.artCantidad ?? 0;
        final newQty = existingQty + (item.artCantidad ?? 0);
        final unitPrice = item.artPrecio ?? existing.rollo.artPrecio ?? 0;
        final updatedRollo = existing.rollo.copyWith(
          artCantidad: newQty,
          artPrecio: unitPrice,
          artDescuento: item.artDescuento ?? existing.rollo.artDescuento,
          totalLinea: unitPrice * newQty,
        );
        await DBRolloTerreno.update(updatedRollo);
        RolloObservacion? updatedObservation = existing.observacion;
        final trimmedObservation = observationText?.trim();
        if (trimmedObservation != null && trimmedObservation.isNotEmpty) {
          final baseObservation = updatedObservation ??
              RolloObservacion(
                codigo: updatedRollo.artCodigo,
                fecha: updatedRollo.fechaTransaccion,
                caja: updatedRollo.cajaDoc,
              );
          final newObservation = baseObservation.copyWith(observaciones: trimmedObservation);
          if (updatedObservation == null) {
            await DBRolloObservaciones.insert(newObservation);
          } else {
            await DBRolloObservaciones.update(newObservation);
          }
          updatedObservation = newObservation;
        }
        final updatedItems = [...state.items];
        updatedItems[existingIndex] = existing.copyWith(
          rollo: updatedRollo,
          observacion: updatedObservation,
        );
        state = state.copyWith(items: updatedItems, isSaving: false);
        return;
      }

      var rolloToInsert = item;
      if (rolloToInsert.lineaVenta == null) {
        final nextLine = await DBRolloTerreno.getNextLineNumber();
        rolloToInsert = rolloToInsert.copyWith(lineaVenta: nextLine.toDouble());
      }
      if (rolloToInsert.totalLinea == null) {
        final qty = rolloToInsert.artCantidad ?? 0;
        final price = rolloToInsert.artPrecio ?? 0;
        rolloToInsert = rolloToInsert.copyWith(totalLinea: qty * price);
      }
      await DBRolloTerreno.insert(rolloToInsert);

      RolloObservacion? savedObservation;
      final trimmedObservation = observationText?.trim();
      if (trimmedObservation != null && trimmedObservation.isNotEmpty) {
        savedObservation = RolloObservacion(
          codigo: rolloToInsert.artCodigo,
          fecha: rolloToInsert.fechaTransaccion,
          caja: rolloToInsert.cajaDoc,
          observaciones: trimmedObservation,
        );
        await DBRolloObservaciones.insert(savedObservation);
      }

      state = state.copyWith(
        items: [...state.items, CartLine(rollo: rolloToInsert, observacion: savedObservation)],
        isSaving: false,
      );
    } catch (error, stackTrace) {
      await _logError('addProduct', error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo agregar el producto al carrito.',
      );
      rethrow;
    }
  }

  Future<void> removeProduct(String codigo) async {
    state = state.copyWith(isSaving: true, resetError: true);
    try {
      final index = state.items.indexWhere(
        (line) => line.rollo.artCodigo == codigo,
      );
      if (index == -1) {
        state = state.copyWith(isSaving: false);
        return;
      }
      final line = state.items[index];
      if (line.rollo.lineaVenta != null) {
        await DBRolloTerreno.deleteByLineaVenta(line.rollo.lineaVenta!);
      } else if (line.rollo.artCodigo != null) {
        await DBRolloTerreno.deleteByCodigo(line.rollo.artCodigo!);
      }
      if (line.observacion?.codigo != null) {
        await DBRolloObservaciones.deleteByCodigo(line.observacion!.codigo!);
      }
      final updatedItems = [...state.items]..removeAt(index);
      state = state.copyWith(items: updatedItems, isSaving: false);
    } catch (error, stackTrace) {
      await _logError('removeProduct', error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo eliminar el producto del carrito.',
      );
    }
  }

  Future<void> updateQuantity(String codigo, int cantidad) async {
    if (cantidad <= 0) {
      await removeProduct(codigo);
      return;
    }
    state = state.copyWith(isSaving: true, resetError: true);
    try {
      final index = state.items.indexWhere(
        (line) => line.rollo.artCodigo == codigo,
      );
      if (index == -1) {
        state = state.copyWith(isSaving: false);
        return;
      }
      final line = state.items[index];
      final unitPrice = line.rollo.artPrecio ?? 0;
      final updatedRollo = line.rollo.copyWith(
        artCantidad: cantidad.toDouble(),
        totalLinea: unitPrice * cantidad,
      );
      await DBRolloTerreno.update(updatedRollo);
      final updatedItems = [...state.items];
      updatedItems[index] = line.copyWith(rollo: updatedRollo);
      state = state.copyWith(items: updatedItems, isSaving: false);
    } catch (error, stackTrace) {
      await _logError('updateQuantity', error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo actualizar la cantidad.',
      );
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isSaving: true, resetError: true);
    try {
      await DBRolloTerreno.deleteAll();
      await DBRolloObservaciones.deleteAll();
      state = state.copyWith(items: const [], isSaving: false);
    } catch (error, stackTrace) {
      await _logError('clearCart', error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo limpiar el carrito.',
      );
    }
  }

  double calculateTotal() => state.total;

  Future<bool> saveCartToVenta({required int numeroVenta}) async {
    if (state.items.isEmpty) {
      state = state.copyWith(errorMessage: 'No hay productos en el carrito.');
      return false;
    }
    state = state.copyWith(isSaving: true, resetError: true);
    final now = DateTime.now();
    final loginState = _ref.read(loginControllerProvider);
    final user = loginState.user;
    final rut = user?.rut ?? '';
    final local = state.items.first.rollo.local ?? user?.prefijo ?? '00';
    final caja = state.items.first.rollo.cajaDoc ?? user?.caja ?? '00';
    final fecha = _formatDate(now);
    final hora = _formatTime(now);
    final numeroDoc = numeroVenta.toString();
    final total = calculateTotal();

    try {
      final cabeza = LocalVentaCabeza(
        local: local,
        tipoDoc: 'NPE',
        numeroDoc: numeroDoc,
        cajaDoc: caja,
        fechaEmision: fecha,
        folioSii: '',
        vencimiento: fecha,
        rutCliente: '',
        direccionDestino: '',
        rutCajera: rut,
        notaPedido: numeroDoc,
        ordenDeCompra: '',
        subtotal: total,
        montoNeto: total,
        montoIva: 0,
        plazo: '',
        impHarina: 0,
        impCarne: 0,
        impRefrescos: 0,
        impLicores: 0,
        impVinos: 0,
        impLight: 0,
        impCerveza: 0,
        impDiesel: 0,
        montoExento: 0,
        montoTotal: total,
        montoLey20956: 0,
        abono: 0,
        montoDonacion: 0,
        horaVenta: hora,
        horaVendedor: hora,
        rutVendedor: rut,
        dctoGlobal: 0,
        porceDescuento: 0,
        formaPago: 'CONTADO',
        despachoPatente: '',
        despachoFecha: '',
        despachoFolio: '',
        despachoHora: '',
        glosaGuia: '',
        usuarioFacturacion: rut,
        observacion: '',
        refTipo: '',
        refFecha: '',
        refNumero: '',
        refGlosa: '',
        nombreCliente: '',
        fonoCliente: '',
        emailCliente: '',
        revision1: 0,
        revision2: 0,
        revision3: 0,
        generarDte: 0,
        numeroImpresora: 0,
        procesada: 0,
        acteco: '',
        imprimePorGrupos: 0,
        tipoTraslado: '',
        montoPropina: 0,
        localTraslado: local,
      );
      await DBVentaCabeza.insert(cabeza);

      for (final line in state.items) {
        final rollo = line.rollo;
        final detalle = LocalVentaDetalle(
          local: local,
          tipoDoc: 'NPE',
          numeroDoc: numeroDoc,
          cajaDoc: caja,
          lineaVenta: rollo.lineaVenta?.toString(),
          fechaEmision: fecha,
          rutCliente: '',
          destinoCliente: '',
          artCodigo: rollo.artCodigo,
          artDescripcion: rollo.artDescripcion,
          artCantidad: rollo.artCantidad,
          artPrecio: rollo.artPrecio,
          artDescuento: rollo.artDescuento,
          porceDescuento: rollo.artDescuento,
          totalLinea: rollo.totalLinea,
          rutVendedor: rut,
          precioCostoCiva: 0,
          almacen: '',
          impuesto: rollo.codImpuesto,
          porceImpuesto: rollo.porceImpuesto,
          montoImpuesto: 0,
          descuento: 0,
          horaVenta: hora,
          usuarioFacturacion: rut,
          folioSii: '',
          fechaViaje: '',
          refTipo: '',
          refNumero: '',
          refFecha: '',
        );
        await DBVentaDetalle.insert(detalle);

        if (line.observacion?.observaciones != null && line.observacion!.observaciones!.isNotEmpty) {
          final observacion = LocalVentaObservacion(
            local: local,
            tipoDoc: 'NPE',
            numeroDoc: numeroDoc,
            fechaEmision: fecha,
            rutCliente: '',
            cajaDoc: caja,
            lineaVenta: rollo.lineaVenta?.toString(),
            codigo: rollo.artCodigo,
            observaciones: line.observacion!.observaciones,
          );
          await DBVentaObservaciones.insert(observacion);
        }
      }

      await DBRolloTerreno.deleteAll();
      await DBRolloObservaciones.deleteAll();
      state = state.copyWith(items: const [], isSaving: false);
      return true;
    } catch (error, stackTrace) {
      await _logError('saveCartToVenta', error, stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo guardar la venta localmente.',
      );
      return false;
    }
  }

  Future<void> syncPendingSales() async {
    try {
      final pendientes = await DBVentaCabeza.getAll(enviado: 0);
      for (final cabeza in pendientes) {
        final numeroDoc = cabeza.numeroDoc;
        if (numeroDoc == null) {
          continue;
        }
        try {
          final cabezaMap = cabeza.toMap()
            ..['enviado'] = 1
            ..['intentos'] = (cabeza.intentos ?? 0) + 1;
          await DBVentaCabeza.update(LocalVentaCabeza.fromMap(cabezaMap));

          final detalles = await DBVentaDetalle.getAll(numeroDoc: numeroDoc);
          for (final detalle in detalles) {
            final map = detalle.toMap()
              ..['enviado'] = 1
              ..['intentos'] = (detalle.intentos ?? 0) + 1;
            await DBVentaDetalle.update(LocalVentaDetalle.fromMap(map));
          }

          final observaciones = await DBVentaObservaciones.getAll(numeroDoc: numeroDoc);
          for (final obs in observaciones) {
            final map = obs.toMap()
              ..['enviado'] = 1
              ..['intentos'] = (obs.intentos ?? 0) + 1;
            await DBVentaObservaciones.update(LocalVentaObservacion.fromMap(map));
          }
        } catch (error, stackTrace) {
          final cabezaMap = cabeza.toMap()
            ..['intentos'] = (cabeza.intentos ?? 0) + 1;
          await DBVentaCabeza.update(LocalVentaCabeza.fromMap(cabezaMap));
          await _logError('syncPendingSalesItem', error, stackTrace);
        }
      }
    } catch (error, stackTrace) {
      await _logError('syncPendingSales', error, stackTrace);
    }
  }

  String _formatDate(DateTime dateTime) =>
      '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';

  Future<void> _logError(String operation, Object error, StackTrace stackTrace) async {
    developer.log('[$operation] $error', error: error, stackTrace: stackTrace, name: 'CartNotifier');
    final log = LogTrack(
      operacion: operation,
      payload: error.toString(),
      createdAt: DateTime.now().toIso8601String(),
      nivel: 'error',
    );
    await DBLogTrack.insert(log);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(ref),
);

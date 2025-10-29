import 'package:flutter/foundation.dart';

/// Modelo que representa un cliente en la base local mae_clientes.
@immutable
class MaeCliente {
  const MaeCliente({
    this.rut,
    this.nombre,
    this.direccion,
    this.codComuna,
    this.comuna,
    this.ciudad,
    this.sector,
    this.fono1,
    this.fono2,
    this.fax,
    this.celular,
    this.giro,
    this.email,
    this.diasCredito,
    this.contacto,
    this.contactoMail,
    this.contactoFono,
    this.descuento,
    this.bloqueo,
    this.bloqueoFacturas,
    this.tipoCliente,
    this.plazo,
    this.cupo,
    this.disponible,
    this.vendedor,
    this.canalCliente,
    this.fechaUltimaModificacion,
    this.localCreacion,
    this.fechaIngreso,
    this.activo,
    this.codPrecio,
    this.precioMenor,
    this.webPassword,
    this.codigoListaPrecios,
    this.tarjetaCupo,
    this.tarjetaDiaPago,
    this.terceraEdad,
    this.dctoSeccion,
    this.dctoDepto,
    this.esInstitucionPublica,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? rut;
  final String? nombre;
  final String? direccion;
  final String? codComuna;
  final String? comuna;
  final String? ciudad;
  final String? sector;
  final String? fono1;
  final String? fono2;
  final String? fax;
  final String? celular;
  final String? giro;
  final String? email;
  final int? diasCredito;
  final String? contacto;
  final String? contactoMail;
  final String? contactoFono;
  final double? descuento;
  final String? bloqueo;
  final String? bloqueoFacturas;
  final String? tipoCliente;
  final String? plazo;
  final double? cupo;
  final double? disponible;
  final String? vendedor;
  final String? canalCliente;
  final String? fechaUltimaModificacion;
  final String? localCreacion;
  final String? fechaIngreso;
  final int? activo;
  final String? codPrecio;
  final double? precioMenor;
  final String? webPassword;
  final String? codigoListaPrecios;
  final double? tarjetaCupo;
  final double? tarjetaDiaPago;
  final int? terceraEdad;
  final String? dctoSeccion;
  final String? dctoDepto;
  final int? esInstitucionPublica;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
        'rut': rut,
        'nombre': nombre,
        'direccion': direccion,
        'cod_comuna': codComuna,
        'comuna': comuna,
        'ciudad': ciudad,
        'sector': sector,
        'fono1': fono1,
        'fono2': fono2,
        'fax': fax,
        'celular': celular,
        'giro': giro,
        'email': email,
        'diascredito': diasCredito,
        'contacto': contacto,
        'contacto_mail': contactoMail,
        'contacto_fono': contactoFono,
        'descuento': descuento,
        'bloqueo': bloqueo,
        'bloqueo_facturas': bloqueoFacturas,
        'tipocliente': tipoCliente,
        'plazo': plazo,
        'cupo': cupo,
        'disponible': disponible,
        'vendedor': vendedor,
        'canalcliente': canalCliente,
        'fechaultimamodificacion': fechaUltimaModificacion,
        'localcreacion': localCreacion,
        'fechaingreso': fechaIngreso,
        'activo': activo,
        'cod_precio': codPrecio,
        'precio_menor': precioMenor,
        'web_password': webPassword,
        'codigo_lista_precios': codigoListaPrecios,
        'tarjeta_cupo': tarjetaCupo,
        'tarjeta_dia_pago': tarjetaDiaPago,
        'tercera_edad': terceraEdad,
        'dcto_seccion': dctoSeccion,
        'dcto_depto': dctoDepto,
        'es_institucion_publica': esInstitucionPublica,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory MaeCliente.fromMap(Map<String, dynamic> json) => MaeCliente(
        rut: json['rut'] as String?,
        nombre: json['nombre'] as String?,
        direccion: json['direccion'] as String?,
        codComuna: json['cod_comuna'] as String?,
        comuna: json['comuna'] as String?,
        ciudad: json['ciudad'] as String?,
        sector: json['sector'] as String?,
        fono1: json['fono1'] as String?,
        fono2: json['fono2'] as String?,
        fax: json['fax'] as String?,
        celular: json['celular'] as String?,
        giro: json['giro'] as String?,
        email: json['email'] as String?,
        diasCredito: json['diascredito'] as int?,
        contacto: json['contacto'] as String?,
        contactoMail: json['contacto_mail'] as String?,
        contactoFono: json['contacto_fono'] as String?,
        descuento: (json['descuento'] as num?)?.toDouble(),
        bloqueo: json['bloqueo'] as String?,
        bloqueoFacturas: json['bloqueo_facturas'] as String?,
        tipoCliente: json['tipocliente'] as String?,
        plazo: json['plazo'] as String?,
        cupo: (json['cupo'] as num?)?.toDouble(),
        disponible: (json['disponible'] as num?)?.toDouble(),
        vendedor: json['vendedor'] as String?,
        canalCliente: json['canalcliente'] as String?,
        fechaUltimaModificacion: json['fechaultimamodificacion'] as String?,
        localCreacion: json['localcreacion'] as String?,
        fechaIngreso: json['fechaingreso'] as String?,
        activo: json['activo'] as int?,
        codPrecio: json['cod_precio'] as String?,
        precioMenor: (json['precio_menor'] as num?)?.toDouble(),
        webPassword: json['web_password'] as String?,
        codigoListaPrecios: json['codigo_lista_precios'] as String?,
        tarjetaCupo: (json['tarjeta_cupo'] as num?)?.toDouble(),
        tarjetaDiaPago: (json['tarjeta_dia_pago'] as num?)?.toDouble(),
        terceraEdad: json['tercera_edad'] as int?,
        dctoSeccion: json['dcto_seccion'] as String?,
        dctoDepto: json['dcto_depto'] as String?,
        esInstitucionPublica: json['es_institucion_publica'] as int?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}

import 'package:flutter/foundation.dart';

/// Modelo para la tabla mae_clientes_destinos.
@immutable
class MaeClienteDestino {
  const MaeClienteDestino({
    this.codigo,
    this.cliente,
    this.descripcion,
    this.codComuna,
    this.vigente,
    this.nombreContacto,
    this.fonoContacto,
    this.emailContacto,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? codigo;
  final String? cliente;
  final String? descripcion;
  final String? codComuna;
  final int? vigente;
  final String? nombreContacto;
  final String? fonoContacto;
  final String? emailContacto;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
        'codigo': codigo,
        'cliente': cliente,
        'descripcion': descripcion,
        'cod_comuna': codComuna,
        'vigente': vigente,
        'nombre_contacto': nombreContacto,
        'fono_contacto': fonoContacto,
        'email_contacto': emailContacto,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory MaeClienteDestino.fromMap(Map<String, dynamic> json) => MaeClienteDestino(
        codigo: json['codigo'] as String?,
        cliente: json['cliente'] as String?,
        descripcion: json['descripcion'] as String?,
        codComuna: json['cod_comuna'] as String?,
        vigente: json['vigente'] as int?,
        nombreContacto: json['nombre_contacto'] as String?,
        fonoContacto: json['fono_contacto'] as String?,
        emailContacto: json['email_contacto'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}

import 'package:flutter/foundation.dart';

/// Datos básicos para registrar un nuevo cliente desde la app.
@immutable
class NuevoCliente {
  const NuevoCliente({
    required this.rut,
    required this.nombre,
    required this.direccion,
    required this.comuna,
    required this.ciudad,
    required this.sector,
    required this.fono1,
    required this.celular,
    required this.giro,
    required this.email,
    required this.contacto,
    required this.institucionPublica,
    required this.vendedor,
  });

  final String rut;
  final String nombre;
  final String direccion;
  final String comuna;
  final String ciudad;
  final String sector;
  final String fono1;
  final String celular;
  final String giro;
  final String email;
  final String contacto;
  final int institucionPublica;
  final String vendedor;

  NuevoCliente copyWith({
    String? rut,
    String? nombre,
    String? direccion,
    String? comuna,
    String? ciudad,
    String? sector,
    String? fono1,
    String? celular,
    String? giro,
    String? email,
    String? contacto,
    int? institucionPublica,
    String? vendedor,
  }) {
    return NuevoCliente(
      rut: rut ?? this.rut,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      comuna: comuna ?? this.comuna,
      ciudad: ciudad ?? this.ciudad,
      sector: sector ?? this.sector,
      fono1: fono1 ?? this.fono1,
      celular: celular ?? this.celular,
      giro: giro ?? this.giro,
      email: email ?? this.email,
      contacto: contacto ?? this.contacto,
      institucionPublica: institucionPublica ?? this.institucionPublica,
      vendedor: vendedor ?? this.vendedor,
    );
  }
}

class MaeClientesDestinos {
  final String codigo;
  final String cliente;
  final String descripcion;
  final String codComuna;
  final int vigente;
  final String nombreContacto;
  final String fonoContacto;
  final String emailContacto;

  MaeClientesDestinos({
    required this.codigo,
    required this.cliente,
    required this.descripcion,
    required this.codComuna,
    required this.vigente,
    required this.nombreContacto,
    required this.fonoContacto,
    required this.emailContacto,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'cliente': cliente,
      'descripcion': descripcion,
      'codComuna': codComuna,
      'vigente': vigente,
      'nombreContacto': nombreContacto,
      'fonoContacto': fonoContacto,
      'emailContacto': emailContacto,
    };
  }

  static MaeClientesDestinos fromMap(Map<String, dynamic> map) {
    return MaeClientesDestinos(
      codigo: map['codigo'],
      cliente: map['cliente'],
      descripcion: map['descripcion'],
      codComuna: map['cod_comuna'],
      vigente: map['vigente'],
      nombreContacto: map['nombre_contacto'],
      fonoContacto: map['fono_contacto'],
      emailContacto: map['email_contacto'],
    );
  }
}

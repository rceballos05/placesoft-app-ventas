class NuevoCliente {
  String? rut;
  String? nombre;
  String? direccion;
  String? comuna;
  String? ciudad;
  String? sector;
  String? fono1;
  String? celular;
  String? giro;
  String? email;
  String? contacto;
  int? institucionPublica;
  String? vendedor;

  NuevoCliente({
    this.rut,
    this.nombre,
    this.direccion,
    this.comuna,
    this.ciudad,
    this.sector,
    this.fono1,
    this.celular,
    this.giro,
    this.email,
    this.contacto,
    this.institucionPublica,
    this.vendedor,
  });

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'nombre': nombre,
      'direccion': direccion,
      'comuna': comuna,
      'ciudad': ciudad,
      'sector': sector,
      'fono1': fono1,
      'celular': celular,
      'giro': giro,
      'email': email,
      'contacto': contacto,
      'esInstitucionPublica': institucionPublica,
      'vendedor': vendedor,
    };
  }
}

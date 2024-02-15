class Cliente {
  String? rut;
  String? nombre;
  String? direccion;
  String? codComuna;
  String? comuna;
  String? ciudad;
  String? sector;
  String? fono1;
  String? fono2;
  String? fax;
  String? celular;
  String? giro;
  String? email;
  int? diasCredito;
  String? contacto;
  String? contactoMail;
  String? contactoFono;
  int? descuento;
  String? bloqueo;
  String? bloqueoFacturas;
  String? tipoCliente;
  String? plaso;
  int? cupo;
  int? disponible;
  String? vendedor;
  String? canalCliente;
  String? localCreacion;
  String? fechaIngreso;
  int? activo;
  int? precioMenor;
  String? codigoListaPrecios;
  int? tarjetaCupo;
  int? tarjetaDiaPago;
  int? terceraEdad;
  String? dectoSeccion;
  String? dctodepto;
  int? esInstitucionPulica;

  Cliente({
    this.activo,
    this.bloqueo,
    this.bloqueoFacturas,
    this.canalCliente,
    this.celular,
    this.ciudad,
    this.codComuna,
    this.codigoListaPrecios,
    this.comuna,
    this.contacto,
    this.contactoFono,
    this.contactoMail,
    this.cupo,
    this.dctodepto,
    this.dectoSeccion,
    this.descuento,
    this.diasCredito,
    this.direccion,
    this.disponible,
    this.email,
    this.esInstitucionPulica,
    this.fax,
    this.fechaIngreso,
    this.fono1,
    this.fono2,
    this.giro,
    this.localCreacion,
    this.nombre,
    this.plaso,
    this.precioMenor,
    this.rut,
    this.sector,
    this.tarjetaCupo,
    this.tarjetaDiaPago,
    this.terceraEdad,
    this.tipoCliente,
    this.vendedor,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      rut: json['rut'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      codComuna: json['codComuna'],
      comuna: json['comuna'],
      ciudad: json['ciudad'],
      sector: json['sector'],
      fono1: json['fono1'],
      fono2: json['fono2'],
      fax: json['fax'],
      celular: json['celular'],
      giro: json['giro'],
      email: json['email'],
      activo: json['activo'],
      bloqueo: json['bloqueo'],
      bloqueoFacturas: json['bloqueoFacturas'],
      canalCliente: json['canalCliente'],
      codigoListaPrecios: json['codigoListaPrecios'],
      contacto: json['contacto'],
      contactoFono: json['contactoFono'],
      contactoMail: json['contactoMail'],
      cupo: json['cupo'],
      dctodepto: json['dctoDepto'],
      dectoSeccion: json['dctoSeccion'],
      descuento: json['descuento'],
      diasCredito: json['diasCredito'],
      disponible: json['disponible'],
      esInstitucionPulica: json['esInstitucionPublica'],
      fechaIngreso: json['fechaIngreso'],
      localCreacion: json['localCreacion'],
      plaso: json['plaso'],
      precioMenor: json['precioMenor'],
      tarjetaCupo: json['tarjetaCupo'],
      tarjetaDiaPago: json['tarjetaDiaPago'],
      terceraEdad: json['terceraEdad'],
      tipoCliente: json['tipoCliente'],
      vendedor: json['vendedor'],
    );
  }
}

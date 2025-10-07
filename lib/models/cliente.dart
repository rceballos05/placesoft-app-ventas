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
  List<Saldo>? saldos;

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
    //required this.saldos,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      rut: json['rut'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      comuna: json['comuna'],
      ciudad: json['ciudad'],
      email: json['email'],
      cupo: json['cupo'],
      plaso: json['plazo'],
      vendedor: json['vendedor'],
    );
  }
}

class Saldo {
  int? id;
  String? rutCliente;
  String? direccionDestino;
  String? numeropagoOrigen;
  String? local;
  int? monto;
  int? utilizado;
  String? usuariocreacion;
  String? numeropagoDestino;
  String? fechapagoDestino;
  String? tipoDoc;
  String? folioDoc;
  Saldo(
      {this.id,
      this.direccionDestino,
      this.fechapagoDestino,
      this.folioDoc,
      this.local,
      this.monto,
      this.numeropagoDestino,
      this.numeropagoOrigen,
      this.rutCliente,
      this.tipoDoc,
      this.usuariocreacion,
      this.utilizado});

  factory Saldo.fromJson(Map<String, dynamic> json) {
    return Saldo(
      id: json["id"],
      rutCliente: json["rutCliente"],
      direccionDestino: json["direccionDestino"],
      fechapagoDestino: json["fechapagoDestino"],
      folioDoc: json["folioDoc"],
      local: json["local"],
      monto: json["monto"],
      numeropagoDestino: json["numeropagoDestino"],
      numeropagoOrigen: json["numeropagoOrigen"],
      tipoDoc: json["tipoDoc"],
      usuariocreacion: json["usuariocreacion"],
      utilizado: json["utilizado"],
    );
  }
}

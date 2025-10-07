class MaeClientes {
  final String rut;
  final String nombre;
  final String direccion;
  final String codComuna;
  final String comuna;
  final String ciudad;
  final String sector;
  final String fono1;
  final String fono2;
  final String fax;
  final String celular;
  final String giro;
  final String email;
  final int diascredito;
  final String contacto;
  final String contactoMail;
  final String contactoFono;
  final double descuento;
  final String bloqueo;
  final String bloqueoFacturas;
  final String tipocliente;
  final String plazo;
  final double cupo;
  final double disponible;
  final String vendedor;
  final String canalcliente;
  final String fechaultimamodificacion;
  final String localcreacion;
  final String fechaingreso;
  final int activo;
  final String codPrecio;
  final int precioMenor;
  final String webPassword;
  final String codigoListaPrecios;
  final double tarjetaCupo;
  final double tarjetaDiaPago;
  final int terceraEdad;
  final String dctoSeccion;
  final String dctoDepto;
  final int esInstitucionPublica;

  MaeClientes({
    required this.rut,
    required this.nombre,
    required this.direccion,
    required this.codComuna,
    required this.comuna,
    required this.ciudad,
    required this.sector,
    required this.fono1,
    required this.fono2,
    required this.fax,
    required this.celular,
    required this.giro,
    required this.email,
    required this.diascredito,
    required this.contacto,
    required this.contactoMail,
    required this.contactoFono,
    required this.descuento,
    required this.bloqueo,
    required this.bloqueoFacturas,
    required this.tipocliente,
    required this.plazo,
    required this.cupo,
    required this.disponible,
    required this.vendedor,
    required this.canalcliente,
    required this.fechaultimamodificacion,
    required this.localcreacion,
    required this.fechaingreso,
    required this.activo,
    required this.codPrecio,
    required this.precioMenor,
    required this.webPassword,
    required this.codigoListaPrecios,
    required this.tarjetaCupo,
    required this.tarjetaDiaPago,
    required this.terceraEdad,
    required this.dctoSeccion,
    required this.dctoDepto,
    required this.esInstitucionPublica,
  });

  Map<String, dynamic> toMap() {
    return {
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
      'diascredito': diascredito,
      'contacto': contacto,
      'contacto_mail': contactoMail,
      'contacto_fono': contactoFono,
      'descuento': descuento,
      'bloqueo': bloqueo,
      'bloqueo_facturas': bloqueoFacturas,
      'tipocliente': tipocliente,
      'plazo': plazo,
      'cupo': cupo,
      'disponible': disponible,
      'vendedor': vendedor,
      'canalcliente': canalcliente,
      'fechaultimamodificacion': fechaultimamodificacion,
      'localcreacion': localcreacion,
      'fechaingreso': fechaingreso,
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
    };
  }

  static MaeClientes fromMap(Map<String, dynamic> map) {
    return MaeClientes(
      rut: map['rut'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      codComuna: map['cod_comuna'],
      comuna: map['comuna'],
      ciudad: map['ciudad'],
      sector: map['sector'],
      fono1: map['fono1'],
      fono2: map['fono2'],
      fax: map['fax'],
      celular: map['celular'],
      giro: map['giro'],
      email: map['email'],
      diascredito: map['diascredito'],
      contacto: map['contacto'],
      contactoMail: map['contacto_mail'],
      contactoFono: map['contacto_fono'],
      descuento: map['descuento'],
      bloqueo: map['bloqueo'],
      bloqueoFacturas: map['bloqueo_facturas'],
      tipocliente: map['tipocliente'],
      plazo: map['plazo'],
      cupo: map['cupo'],
      disponible: map['disponible'],
      vendedor: map['vendedor'],
      canalcliente: map['canalcliente'],
      fechaultimamodificacion: map['fechaultimamodificacion'],
      localcreacion: "00",
      fechaingreso: map['fechaingreso'],
      activo: map['activo'],
      codPrecio: map['cod_precio'],
      precioMenor: 0,
      webPassword: map['web_password'],
      codigoListaPrecios: map['codigo_lista_precios'],
      tarjetaCupo: map['tarjeta_cupo'],
      tarjetaDiaPago: map['tarjeta_dia_pago'],
      terceraEdad: map['tercera_edad'],
      dctoSeccion: map['dcto_seccion'],
      dctoDepto: map['dcto_depto'],
      esInstitucionPublica: map['es_institucion_publica'],
    );
  }
}

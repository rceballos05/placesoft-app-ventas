class VentaCabeza {
  String? local;
  String? tipoDoc;
  String? numeroDoc;
  String? cajaDoc;
  String? fechaEmision;
  String? foliosii;
  String? rutCliente;
  String? direccionDestino;
  String? rutCajera;
  String? notaPedido;
  String? ordenDeCompra;
  double? subtotal;
  double? montoNeto;
  double? montoIva;
  String? plazo;
  double? impHarina;
  double? impCarne;
  double? impRefrescos;
  double? impLicores;
  double? impVinos;
  double? impLight;
  double? impCerveza;
  double? impDiesel;
  double? montoExento;
  double? montoTotal;
  double? montoLey20956;
  double? abono;
  double? montoDonacion;
  String? rutVendedor;
  double? dctoglobal;
  double? porceDescuento;
  String? formapago;
  String? despachoPatente;
  String? observacion;
  String? despachoFolio;
  String? despachoHora;
  String? glosaGuia;
  String? usuarioFacturacion;
  String? refTipo;
  String? refNumero;
  String? refGlosa;
  String? nombreCliente;
  String? fonoCliente;
  String? emailCliente;
  int? revision1;
  int? revision2;
  int? revision3;
  int? generarDte;
  String? numeroImpresora;
  int? procesada;
  String? acteco;
  String? tipoTraslado;
  double? montoPropina;
  String? localTraslado;
  VentaCabeza({
    this.tipoDoc,
    this.abono,
    this.cajaDoc,
    this.dctoglobal,
    this.despachoPatente,
    this.direccionDestino,
    this.fechaEmision,
    this.foliosii,
    this.formapago,
    this.impCarne,
    this.impCerveza,
    this.impDiesel,
    this.impHarina,
    this.impLicores,
    this.impLight,
    this.impRefrescos,
    this.impVinos,
    this.local,
    this.montoDonacion,
    this.montoExento,
    this.montoIva,
    this.montoLey20956,
    this.montoNeto,
    this.montoTotal,
    this.notaPedido,
    this.observacion,
    this.numeroDoc,
    this.ordenDeCompra,
    this.plazo,
    this.porceDescuento,
    this.rutCajera,
    this.rutCliente,
    this.subtotal,
    this.rutVendedor,
    this.acteco,
    this.despachoFolio,
    this.despachoHora,
    this.emailCliente,
    this.fonoCliente,
    this.generarDte,
    this.glosaGuia,
    this.localTraslado,
    this.montoPropina,
    this.nombreCliente,
    this.numeroImpresora,
    this.procesada,
    this.refGlosa,
    this.refNumero,
    this.refTipo,
    this.revision1,
    this.revision2,
    this.revision3,
    this.tipoTraslado,
    this.usuarioFacturacion,
  });

  Map<String, dynamic> toJson() {
    return {
      "local": local,
      "tipoDoc": tipoDoc,
      "numeroDoc": numeroDoc,
      "cajaDoc": cajaDoc,
      "fechaEmision": fechaEmision,
      "foliosii": foliosii,
      "rutCliente": rutCliente,
      "direccionDestino": direccionDestino,
      "rutCajera": rutCajera,
      "notaPedido": notaPedido,
      "ordenDeCompra": ordenDeCompra,
      "subtotal": subtotal,
      "montoNeto": montoNeto,
      "montoIva": montoIva,
      "plazo": plazo,
      "impHarina": impHarina,
      "impCarne": impCarne,
      "impRefrescos": impRefrescos,
      "impLicores": impLicores,
      "impVinos": impVinos,
      "impLight": impLight,
      "impCerveza": impCerveza,
      "impDiesel": impDiesel,
      "montoExento": montoExento,
      "montoTotal": montoTotal,
      "montoLey20956": montoLey20956,
      "abono": abono,
      "montoDonacion": montoDonacion,
      "rutVendedor": rutVendedor,
      "dctoglobal": dctoglobal,
      "porceDescuento": porceDescuento,
      "formapago": formapago,
      "despachoPatente": despachoPatente,
      "despachoFolio": despachoFolio,
      "despachoHora": despachoHora,
      "glosaGuia": glosaGuia,
      "usuarioFacturacion": usuarioFacturacion,
      "observacion": observacion,
      "refTipo": refTipo,
      "refNumero": refNumero,
      "refGlosa": refGlosa,
      "nombreCliente": nombreCliente,
      "fonoCliente": fonoCliente,
      "emailCliente": emailCliente,
      "revision1": revision1,
      "revision2": revision2,
      "revision3": revision3,
      "generarDte": generarDte,
      "numeroImpresora": numeroImpresora,
      "procesada": procesada,
      "acteco": acteco,
      "tipoTraslado": tipoTraslado,
      "montoPropina": montoPropina,
      "localTraslado": localTraslado
    };
  }

  factory VentaCabeza.fromJson(Map<String, dynamic> json) {
    return VentaCabeza(
      numeroDoc: json['numeroDoc'],
      fechaEmision: "" + json['fechaEmision'] + " " + json['horaVendedor'],
      rutVendedor: json['rutVendedor'],
      rutCliente: json['rutCliente'],
      nombreCliente: json['nombreCliente'],
      montoTotal: double.parse(json['montoTotal'].toString()),
      observacion: json['observacion'],
    );
  }
}

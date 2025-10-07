class VentaObservaciones {
  String? local;
  String? tipoDoc;
  String? numeroDoc;
  String? fechaEmision;
  String? rutCliente;
  String? cajaDoc;
  String? lineaVenta;
  String? codigo;
  String? observaciones;
  VentaObservaciones({
    this.cajaDoc,
    this.codigo,
    this.fechaEmision,
    this.lineaVenta,
    this.local,
    this.numeroDoc,
    this.observaciones,
    this.rutCliente,
    this.tipoDoc,
  });
  Map<String, dynamic> toJson() {
    return {
      "local": local,
      "tipoDoc": tipoDoc,
      "numeroDoc": numeroDoc,
      "fechaEmision": fechaEmision,
      "rutCliente": rutCliente,
      "cajaDoc": cajaDoc,
      "lineaVenta": lineaVenta,
      "codigo": codigo,
      "observaciones": observaciones
    };
  }
}

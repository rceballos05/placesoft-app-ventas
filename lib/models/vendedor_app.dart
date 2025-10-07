class VendedorAppModel {
  String? rut;
  String? prefijo;
  String? cpanel_prefijo;
  String? caja;
  double? descuento;
  String? modoLocal;
  String? downloadData;
  String? errorEnvio;
  String? updateCliente;

  VendedorAppModel(
      {this.rut,
      this.prefijo,
      this.caja,
      this.cpanel_prefijo,
      this.descuento,
      this.modoLocal,
      this.downloadData,
      this.errorEnvio,
      this.updateCliente});
  factory VendedorAppModel.fromJson(Map<String, dynamic> json) {
    return VendedorAppModel(
      rut: json["rut"],
      prefijo: json["prefijo"],
      caja: json["caja"],
      cpanel_prefijo: json["cpanelPrefijo"],
      descuento: double.parse(json["maxDctoProducto"].toString()),
      modoLocal: json["modoLocal"].toString(),
      downloadData: json["downloadData"].toString(),
      errorEnvio: json["errorEnvio"].toString(),
      updateCliente: json["upadateCliente"].toString(),
    );
  }
}

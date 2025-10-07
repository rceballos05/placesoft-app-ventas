class DownloadDataDto {
  String? prefijo;
  String? caja;
  String? rut;

  DownloadDataDto({
    this.rut,
    this.caja,
    this.prefijo,
  });

  Map<String, dynamic> toMap() {
    return {
      "prefijo": prefijo,
      "caja": caja,
      "rut": rut,
    };
  }
}

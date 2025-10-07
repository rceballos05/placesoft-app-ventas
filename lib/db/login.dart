class LoginDb {
  String? rut;
  String? prefijo;
  String? caja;
  String? password;
  String? urlImagen;
  double? maxDctoPermitido;

  LoginDb(
      {this.caja,
      this.password,
      this.prefijo,
      this.urlImagen,
      this.rut,
      this.maxDctoPermitido});

  Map<String, dynamic> toMap() {
    return {
      "rut": rut,
      "prefijo": prefijo,
      "caja": caja,
      "password": password,
      "url_imagen": urlImagen,
      "max_dcto": maxDctoPermitido
    };
  }

  factory LoginDb.fromJson(Map<String, dynamic> json) {
    return LoginDb(
      rut: json["rut"],
      caja: json["caja"],
      prefijo: json["prefijo"],
      password: json["password"],
      urlImagen: json["url_imagen"],
      maxDctoPermitido: json["max_dcto_permitido"],
    );
  }
}

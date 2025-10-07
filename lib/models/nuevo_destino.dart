class NuevoDestino {
  String? codigo;
  String? cliente;
  String? descripcion;
  String? comuna;
  bool? vigente;
  String? nombreContacto;
  String? fonoContacto;
  String? emailContacto;

  NuevoDestino({
    this.cliente,
    this.codigo,
    this.comuna,
    this.descripcion,
    this.emailContacto,
    this.fonoContacto,
    this.nombreContacto,
    this.vigente,
  });

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo,
      "cliente": cliente,
      "descripcion": descripcion,
      "comuna": comuna,
      "vigente": vigente,
      "nombreContacto": nombreContacto,
      "fonoContacto": fonoContacto,
      "emailContacto": emailContacto
    };
  }
}

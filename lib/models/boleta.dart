class Boleta {
  int? numero;
  Boleta({this.numero});
  factory Boleta.fromJSon(Map<String, dynamic> json) {
    return Boleta(
      numero: int.parse(json["numero"]),
    );
  }
}

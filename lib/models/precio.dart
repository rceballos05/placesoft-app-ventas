class Precio {
  String? codigo;
  int? precio;
  Precio({this.precio, this.codigo});
  factory Precio.fromJson(Map<String, dynamic> json) {
    return Precio(
      codigo: json['codigo'],
      precio: json['precio'],
    );
  }
}

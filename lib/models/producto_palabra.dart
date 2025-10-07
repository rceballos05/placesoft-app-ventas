class ProductoSearch {
  String? codigo;
  String? nombre;
  int? precio;

  ProductoSearch({
    this.codigo,
    this.nombre,
    this.precio,
  });

  factory ProductoSearch.fromJson(Map<String, dynamic> json) {
    return ProductoSearch(
      codigo: json['codigo'],
      nombre: json['nombre'],
      precio: int.parse(json["precio"].toString()),
    );
  }
}

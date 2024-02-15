class Categoria {
  String? codigo;
  String? nombre;
  Categoria({
    this.codigo,
    this.nombre,
  });
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      codigo: json['codigo'],
      nombre: json['nombre'],
    );
  }
}

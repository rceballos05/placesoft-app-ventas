class EmailDto {
  String? to;
  String? cc;
  List<Articulo>? articulos;
  EmailDto({
    this.articulos,
    this.cc,
    this.to,
  });
  Map<String, dynamic> toJson() {
    return {"to": to, "cc": cc, "articulos": articulos};
  }
}

class Articulo {
  String? codigobarra;
  String? descripcion;
  int? cantidad;
  int? total;
  Articulo({
    this.codigobarra,
    this.cantidad,
    this.descripcion,
    this.total,
  });
  Map<String, dynamic> toJson() {
    return {
      "codigobarra": codigobarra,
      "descripcion": descripcion,
      "cantidad": cantidad,
      "total": total
    };
  }
}

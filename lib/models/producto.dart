class Producto {
  String? codigobarra;
  String? descripcion;
  String? codSeccion;
  String? codDepto;
  String? codLinea;
  String? codMarca;
  String? uniMedida;
  String? contenido;
  int? precioCostoCiva;
  int? margenBase;
  bool? artDescontinuado;
  int? descuento;
  int? unicompramax;
  int? unicompramin;
  int? stock;
  //Foto? fotos;
  int? precio;
  Producto(
      {this.artDescontinuado,
      this.codDepto,
      this.codLinea,
      this.codMarca,
      this.codSeccion,
      this.codigobarra,
      this.contenido,
      this.descripcion,
      this.descuento,
      //this.fotos,
      this.margenBase,
      this.precioCostoCiva,
      this.stock,
      this.uniMedida,
      this.unicompramax,
      this.unicompramin,
      this.precio});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codigobarra: json['codigobarra'],
      descripcion: json['descripcion'],
      codSeccion: json['codSeccion'],
      codDepto: json['codDepto'],
      codLinea: json['codLinea'],
      codMarca: json['codMarca'],
      uniMedida: json['uniMedida'],
      contenido: json['contenido'],
      precioCostoCiva: json['precioCostoCiva'].round(),
      margenBase: json['margenBase'],
      artDescontinuado: json['artDescontinuado'],
      descuento: json['descuento'],
      unicompramax: json['unicompramax'],
      unicompramin: json['unicompramin'],
      stock: json['stock'],
      precio: json['precioFinal'],
    );
  }
}

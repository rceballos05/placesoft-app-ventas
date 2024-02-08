class VendedorAppModel {
  String rut;
  List<Prefijo> prefijos;

  VendedorAppModel({required this.rut, required this.prefijos});
}

class Prefijo {
  String? nombre;
  String? numero;
}

class User {
  String? rut;
  String? nombre;
  String? correo;
  String? local;
  String? comuna;
  String? ciudad;
  String? direccion;

  User({
    this.correo,
    this.nombre,
    this.rut,
    this.ciudad,
    this.comuna,
    this.local,
    this.direccion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      rut: json["rut"],
      nombre: json["nombre"],
      correo: json["email"],
      comuna: json["comuna"],
      ciudad: json["ciudad"],
      local: json["local"],
      direccion: json["direccion"],
    );
  }
}

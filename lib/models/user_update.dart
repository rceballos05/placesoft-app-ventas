class UserUpdate {
  String? rut;
  String? usuario;
  String? nombre;
  String? labor;
  String? correo;

  UserUpdate({this.correo, this.labor, this.nombre, this.rut, this.usuario});

  Map<String, dynamic> toJson() {
    return {
      "rut": rut,
      "usuario": usuario,
      "nombre": nombre,
      "labor": labor,
      "email": correo
    };
  }
}

class UserPass {
  String? clave;
  String? usuario;

  UserPass({this.clave, this.usuario});
  Map<String, dynamic> toJson() {
    return {"usuario": usuario, "clave": clave};
  }
}

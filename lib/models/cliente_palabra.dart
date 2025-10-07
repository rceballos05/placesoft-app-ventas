class ClientePalabra {
  String? rut;
  String? nombre;
  String? codDestino;
  String? direccionDestino;
  String? nombreContacto;
  String? fonoContacto;
  String? emailContacto;
  String? codComuna;
  String? comuna;

  ClientePalabra({
    this.rut,
    this.nombre,
    this.codDestino,
    this.direccionDestino,
    this.nombreContacto,
    this.fonoContacto,
    this.emailContacto,
    this.codComuna,
    this.comuna,
  });
  factory ClientePalabra.fromJson(Map<String, dynamic> json) {
    return ClientePalabra(
      rut: json['rut'],
      nombre: json['nombre'],
      codDestino: json['codigoDestino'],
      direccionDestino: json['direccionDestino'],
      nombreContacto: json['nombreContacto'],
      fonoContacto: json['fonoContacto'],
      emailContacto: json['emailContacto'],
      codComuna: json['codComuna'],
      comuna: json['comuna'],
    );
  }
}

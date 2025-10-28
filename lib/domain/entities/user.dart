/// Represents an authenticated user inside the application domain.
class User {
  const User(
      {required this.rut,
      required this.prefijo,
      required this.nombre,
      required this.caja,
      required this.maxDcto});

  /// Unique identifier for the seller.
  final String rut;
  final String nombre;
  final String caja;

  /// Company prefix associated to the seller.
  final String prefijo;
  final double maxDcto;
}

/// Represents an authenticated user inside the application domain.
class User {
  const User({required this.rut, required this.prefijo});

  /// Unique identifier for the seller.
  final String rut;

  /// Company prefix associated to the seller.
  final String prefijo;
}

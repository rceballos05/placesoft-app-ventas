import 'package:flutter/services.dart';

/// Utility helpers for handling Chilean RUT formatting and validation.
class RutUtils {
  /// Removes formatting characters and keeps only digits or the verifier digit K.
  static String clean(String rut) {
    return rut.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase().trim();
  }

  /// Returns the visual Chilean format: 11.111.111-1.
  static String format(String rut) {
    String cleanRut = clean(rut);
    if (cleanRut.isEmpty) return '';
    if (cleanRut.length < 2) return cleanRut;

    String body = cleanRut.substring(0, cleanRut.length - 1);
    String dv = cleanRut.substring(cleanRut.length - 1);

    final bodyDigits = RegExp(r'^\d+$');
    if (!bodyDigits.hasMatch(body)) {
      return cleanRut;
    }

    final buffer = StringBuffer();
    int counter = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      buffer.write(body[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }
    String formattedBody = buffer.toString().split('').reversed.join();
    return '$formattedBody-$dv';
  }

  /// Checks if the provided [rut] is valid using the modulo 11 algorithm.
  static bool isValid(String rut) {
    final cleanRut = clean(rut);
    if (cleanRut.length < 8) return false;

    final body = cleanRut.substring(0, cleanRut.length - 1);
    final dv = cleanRut.substring(cleanRut.length - 1).toUpperCase();

    if (!RegExp(r'^\d+$').hasMatch(body)) {
      return false;
    }
    if (!RegExp(r'^[0-9K]$').hasMatch(dv)) {
      return false;
    }

    int suma = 0;
    int multiplo = 2;
    for (int i = body.length - 1; i >= 0; i--) {
      suma += int.parse(body[i]) * multiplo;
      multiplo = multiplo == 7 ? 2 : multiplo + 1;
    }
    int dvEsperado = 11 - (suma % 11);
    String dvCalculado =
        dvEsperado == 11 ? '0' : dvEsperado == 10 ? 'K' : dvEsperado.toString();
    return dv == dvCalculado;
  }

  /// Returns the RUT without formatting, padded with zeros to 10 characters.
  static String toDatabaseFormat(String rut) {
    String cleanRut = clean(rut);
    if (cleanRut.isEmpty) {
      return cleanRut;
    }
    return cleanRut.padLeft(10, '0');
  }
}

/// Text input formatter that formats RUT input as the user types.
class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = RutUtils.clean(newValue.text);
    final limited = sanitized.length > 9 ? sanitized.substring(0, 9) : sanitized;
    final formatted = RutUtils.format(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

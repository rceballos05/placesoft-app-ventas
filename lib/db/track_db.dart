import 'package:aplicacion_ventas/db/settings_db.dart';
import 'package:aplicacion_ventas/models/log_track.dart';
import 'package:aplicacion_ventas/models/track.dart';

class DBTrack {
  const DBTrack._();

  static Future<bool> insert(TrackDto track) async {
    final log = LogTrack(
      operacion: 'track',
      payload: track.toJson(),
      createdAt: DateTime.now().toIso8601String(),
      nivel: 'info',
    );
    await DBLogTrack.insert(log);
    return true;
  }
}

# Changelog

## Unreleased
- Reorganización definitiva de la carpeta `lib/` siguiendo la arquitectura limpia propuesta.
  - `pages/`, `widgets/` y `router/` migrados a `presentation/` con rutas centralizadas en `AppRouter`.
  - Creación de `data/datasources/remote/` para los orígenes `AuthRemoteDataSource`, `ProductRemoteDataSource` y `SyncRemoteDataSource`.
  - Contratos de repositorios movidos a `domain/entities/contracts/` para mantener el dominio sin dependencias externas.
- Limpieza de código legado: eliminación de `functions/`, `models/`, `db/` y `statics/` (utilizaban la implementación antigua sin Riverpod).
- Actualización de importaciones para reflejar la nueva estructura (`core/utils/failure.dart`, proveedores y repositorios).
- `main.dart` ahora consume `AppRouter` y concentra la inicialización de tema y `ScreenUtil`.

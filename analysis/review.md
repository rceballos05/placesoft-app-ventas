# UI/UX y Arquitectura - Observaciones Iniciales

Este documento contiene hallazgos preliminares sobre problemas de responsividad, arquitectura y lógica detectados durante la revisión del código existente.

## Hallazgos destacados

- `LoginPage` inicializa `ScreenUtil` dentro del método `build` y fija anchos máximos, lo que genera resultados inconsistentes en tablets o pantallas pequeñas. 【F:lib/pages/login.dart†L46-L99】
- `_HomeState` usa `setState` dentro de `initState` y `build`, produciendo reconstrucciones infinitas y duplicación de datos locales. 【F:lib/pages/home.dart†L32-L569】
- El proyecto depende de variables globales mutables para compartir estado, lo que dificulta testeo y escalado. 【F:lib/statics/globals.dart†L12-L58】
- Se definen estilos de texto basados en `ScreenUtil` en un archivo global sin garantizar su inicialización antes del uso, comprometiendo la responsividad. 【F:lib/statics/statics.dart†L1-L74】
- Páginas como `CartPage` fijan alturas y márgenes estáticos sin adaptar el layout a la orientación o densidad de píxeles. 【F:lib/pages/cart_page.dart†L13-L64】


# Convenciones — gym-assistant (Flutter)

> La estructura de carpetas y de capas la define `specs/languageArchitecture.md`
> (Clean Architecture). Este documento cubre herramientas y reglas de código.

## Gestión de estado: Riverpod (obligatorio)
- Toda la gestión de estado de negocio se hace con **Riverpod**. No usar Provider,
  Bloc, GetX ni `setState` para estado que no sea puramente local de un widget.
- Paquete: `flutter_riverpod` (añadir con `flutter pub add flutter_riverpod`).
- La app se envuelve en un `ProviderScope` en el `main`.
- Patrones:
  - Estado asíncrono (sesión, queries a Supabase) → `AsyncNotifier` / `FutureProvider`
    / `StreamProvider` según el caso. Para el estado de auth, un `StreamProvider`
    sobre `onAuthStateChange` encaja bien.
  - Acceso al cliente de Supabase → exponerlo mediante un `Provider` en vez de usar
    el singleton global directamente en los widgets.
- Evitar lógica de negocio dentro de los widgets; los widgets consumen providers.
- Riverpod vive en la capa de presentation (gestores de estado), según la estructura
  de capas de `specs/languageArchitecture.md`.

## Idioma
- Código, nombres de variables, clases y archivos: **inglés**.
- Comentarios y textos visibles de la UI: **español**.

## Manejo de errores
- Nada de errores silenciosos.
- Capturar `AuthException` y errores de Supabase y traducirlos a mensajes legibles
  en español para el usuario.
- En estados asíncronos de Riverpod, manejar siempre los tres estados:
  loading, error y data.

## Claves y configuración
- URL y clave pública de Supabase: SOLO en `app/env.json`, leídas con
  `String.fromEnvironment('SUPABASE_URL')` y `String.fromEnvironment('SUPABASE_ANON_KEY')`.
- Nunca hardcodear claves. Nunca `flutter_dotenv`. Nunca un `.env` en `app/`.
- Lanzar siempre con `flutter run --dart-define-from-file=env.json`.

## Estilo de código
- Respetar `flutter analyze` sin warnings antes de dar una tarea por terminada.
- Nombres descriptivos; nada de abreviaturas crípticas.
- Widgets pequeños y componibles antes que widgets gigantes.

## MVP: funcionalidad antes que estética
El objetivo del MVP es que el flujo de datos funcione. Las pantallas pueden ir sin
estilo (widgets básicos). Lo bonito viene después y es lo fácil.

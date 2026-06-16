# CLAUDE.md — gym-assistant

Memoria operativa del proyecto. Léeme al empezar cada sesión.
Para detalle de arquitectura, consulta los archivos de `specs/`.

## Qué es
MVP de un asistente de gimnasio y nutrición. El usuario registra comidas y
ejercicio, ve su progreso de calorías diarias, y en fases futuras un agente de
IA (visión + LLM) automatizará parte del registro. Proyecto de portafolio:
prioriza código limpio y decisiones de arquitectura defendibles sobre estética.

## Stack
- **Frontend:** Flutter (carpeta `app/`)
- **Auth + base de datos:** Supabase (Postgres + Auth + API)
- **Automatización / orquestación:** n8n en Docker (carpeta `infra/`)
- **Gestión de estado en Flutter:** Riverpod (obligatorio, ver `specs/conventions.md`)

## Estructura del monorepo
- `app/`    → proyecto Flutter (la app).
- `infra/`  → Docker Compose con n8n. Contiene `.env` (NO versionado).
- `db/`     → scripts SQL de Supabase (`schema.sql`). El esquema ya está aplicado.
- `specs/`  → documentación de arquitectura. **Léela antes de decisiones de diseño.**

## Comandos clave (ejecutar dentro de `app/`)
- Lanzar la app:    `flutter run --dart-define-from-file=env.json`
- Añadir paquete:   `flutter pub add <paquete>`
- Analizar/lint:    `flutter analyze`
- Tests:            `flutter test`

> La app SIEMPRE se lanza con `--dart-define-from-file=env.json`. Sin ese flag
> las claves salen vacías y Supabase no inicializa.

## Reglas no negociables
- **Claves:** la URL y la clave pública de Supabase viven SOLO en `app/env.json`
  (en la raíz del proyecto Flutter). Se leen con `String.fromEnvironment(...)`.
  - NUNCA hardcodear claves en el código.
  - NUNCA usar `flutter_dotenv` ni crear un `.env` dentro de `app/`.
  - La clave `service_role` / `secret` de Supabase JAMÁS toca Flutter. Solo vive
    dentro de n8n (gestor de credenciales cifrado).
- **Base de datos:** el esquema (`db/schema.sql`) ya está aplicado en Supabase y
  está CERRADO. No lo modifiques sin que se pida explícitamente. El trigger que
  crea la fila en `profiles` al registrarse un usuario ya existe; no lo dupliques.
- **Arquitectura de datos:** ESCRIBIR pasa por n8n (ahí se enchufa la IA luego);
  LEER se hace directo desde Flutter a Supabase. Ver `specs/architecture.md`.
- **Specs mandan:** si algo en un prompt contradice `specs/`, prioriza `specs/`
  y avisa del conflicto antes de continuar.

## Convenciones rápidas
- Gestión de estado: **Riverpod**. No usar setState para estado de negocio ni
  otras librerías (Provider, Bloc, GetX). Detalle en `specs/conventions.md`.
- Estructura de capas: **Clean Architecture** según `specs/languageArchitecture.md`
  (domain / data / presentation, dependencias solo hacia adentro).
- Idioma: código y nombres en inglés; comentarios y textos de UI en español.
- Errores: nada de errores silenciosos. Capturar `AuthException` / errores de
  Supabase y mostrar mensajes legibles al usuario.
- Estilos: estilo y theme según specs/design-system.md; toda pantalla consume del theme central, nunca    valores hex sueltos.

## Flujo de trabajo
- Para features no triviales, propón primero un PLAN (qué archivos, qué hace cada
  uno) y espera revisión antes de escribir código.
- Commits pequeños y por unidad de trabajo coherente (ej. `feat: auth login/registro`).
- Antes del primer commit, verifica que `env.json` y los `.env` están en `.gitignore`.

## No tocar
- `app/env.json`, `infra/.env` (secretos).
- `db/schema.sql` y el esquema ya aplicado en Supabase.

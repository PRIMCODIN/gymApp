# Base de datos — gym-assistant (Supabase / Postgres)

El esquema ya está aplicado en Supabase (ver `db/schema.sql`). Está CERRADO: no
modificar sin petición explícita. Este documento es la referencia de cómo son
los datos para que el código Flutter y los workflows de n8n no tengan que adivinar.

## Tablas

### profiles
Extiende `auth.users`. Una fila por usuario, creada automáticamente por un trigger
al registrarse.
- `id` (uuid, PK) = `auth.users.id`
- `nombre` (text, nullable)
- `objetivo_kcal_diario` (integer, default 2000)
- `created_at` (timestamptz)

### food_logs
Registros de comida. Los macros pueden venir vacíos en fase 1 (se rellenan a mano
o con un valor); en fase 2 los rellena la visión por IA.
- `id` (bigint identity, PK)
- `user_id` (uuid, FK → auth.users, on delete cascade)
- `fecha` (date, default hoy)
- `descripcion` (text)
- `kcal` (integer, nullable)
- `proteina`, `carbos`, `grasa` (numeric, nullable)
- `created_at` (timestamptz)

### exercise_logs
Registros sueltos de ejercicio.
- `id` (bigint identity, PK)
- `user_id` (uuid, FK → auth.users, on delete cascade)
- `fecha` (date, default hoy)
- `nombre` (text)
- `series`, `reps` (integer, nullable)
- `peso` (numeric, nullable)
- `created_at` (timestamptz)

### routines
Rutinas del usuario. Creada para fases futuras; en el MVP puede no usarse aún.
- `id` (bigint identity, PK)
- `user_id` (uuid, FK → auth.users, on delete cascade)
- `nombre` (text)
- `created_at` (timestamptz)

### routine_exercises
Ejercicios dentro de una rutina. No tiene `user_id` propio: la propiedad se valida
a través de la rutina padre.
- `id` (bigint identity, PK)
- `routine_id` (bigint, FK → routines, on delete cascade)
- `dia_semana` (smallint, 1=lunes ... 7=domingo)
- `nombre_ejercicio` (text)
- `orden` (smallint)
- `series`, `reps` (integer)
- `pct_carga` (numeric, % de carga)

## Row Level Security
- RLS activado en las cinco tablas.
- `profiles`: políticas de select y update sobre la fila propia (`auth.uid() = id`).
- `food_logs`, `exercise_logs`, `routines`: política `ALL` sobre filas propias
  (`auth.uid() = user_id`), con `with check` para validar también inserts/updates.
- `routine_exercises`: política `ALL` validada a través de la rutina padre
  (la rutina debe pertenecer al usuario).

> Si una query "no devuelve nada" y los datos existen, sospecha primero del RLS:
> es el punto donde más se tropieza con Supabase Auth.

## Trigger
`handle_new_user()` se dispara tras un INSERT en `auth.users` e inserta la fila
correspondiente en `profiles`. Es `security definer` para poder escribir saltando
el RLS. El `nombre` se toma de los metadatos del registro si se envían.

## Acceso desde la app
- **Lectura:** directa desde Flutter con `supabase_flutter` (respeta el RLS con la
  sesión del usuario).
- **Escritura:** vía webhooks de n8n (ver `specs/architecture.md`).

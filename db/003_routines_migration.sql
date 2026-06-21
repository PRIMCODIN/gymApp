-- ============================================================
-- gym-assistant — Migración 003: alinear routine_exercises con el catálogo
-- routine_exercises se creó ANTES del catálogo de ejercicios: guardaba el
-- ejercicio como texto libre (nombre_ejercicio) y un modelo de carga por
-- porcentaje (pct_carga) que no encaja con el flujo Hevy. Esta migración:
--   · Añade exercise_id (FK al catálogo) para que la plantilla referencie el
--     mismo ejercicio que luego usa la sesión -> PREVIOUS fiable al instanciar.
--   · Conserva nombre_ejercicio como SNAPSHOT (igual que workout_sets): blinda
--     la plantilla si el ejercicio del catálogo se borra/renombra.
--   · Simplifica el modelo de plantilla a "lista de ejercicios + nº de series
--     objetivo" (sin peso/reps por set; eso lo aporta el PREVIOUS en la sesión).
--   · dia_semana se mantiene (rutinas ligadas a día).
-- Pegar en el SQL Editor de Supabase y ejecutar una vez.
-- ============================================================

-- 1. Añadir FK al catálogo. Nullable + on delete set null: si se borra el
--    ejercicio del catálogo, la fila de la plantilla sobrevive con su snapshot.
alter table public.routine_exercises
  add column exercise_id bigint references public.exercises (id) on delete set null;

-- 2. series_objetivo: número de series planificadas para ese ejercicio.
--    Reutilizamos la columna `series` existente renombrándola para que el
--    nombre exprese la intención (objetivo, no realizado).
alter table public.routine_exercises
  rename column series to series_objetivo;

-- 3. Retirar el modelo de carga por porcentaje y las reps objetivo:
--    la decisión es plantilla SIN peso/reps por set. El peso/reps reales los
--    pone el usuario en la sesión, con el PREVIOUS como referencia.
alter table public.routine_exercises
  drop column if exists pct_carga;

alter table public.routine_exercises
  drop column if exists reps;

-- 4. Índice para leer los ejercicios de una rutina en orden.
create index if not exists routine_exercises_routine_orden_idx
  on public.routine_exercises (routine_id, dia_semana, orden);

-- ============================================================
-- Estado final de routine_exercises:
--   id, routine_id (FK), dia_semana (1-7, nullable),
--   exercise_id (FK catálogo, nullable),
--   nombre_ejercicio (text, snapshot), orden (smallint),
--   series_objetivo (int)
-- RLS existente (validación vía rutina padre) sigue vigente, no se toca.
-- ============================================================
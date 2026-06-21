-- ============================================================
-- gym-assistant — Esquema Entreno (catálogo + sesiones + sets)
-- Parte de EJECUCIÓN del entreno, estilo Hevy:
--   catálogo de ejercicios -> rutina (plantilla) -> workout (sesión) -> sets.
-- Las tablas routines / routine_exercises (plantillas) NO se tocan aquí.
-- Pegar entero en el SQL Editor de Supabase y ejecutar una vez.
-- ============================================================

-- ============================================================
-- 1. CATÁLOGO DE EJERCICIOS
-- ============================================================
-- Lista de ejercicios elegibles. Dos tipos en la misma tabla:
--   · Predefinidos (user_id NULL): sembrados por nosotros, visibles para todos.
--   · Personalizados (user_id = usuario): los crea el usuario si su ejercicio
--     no está en la lista. Solo los ve su dueño.
-- El grupo muscular vive AQUÍ (no en cada set): un ejercicio "sabe" su músculo.
create table public.exercises (
  id              bigint generated always as identity primary key,
  -- NULL = ejercicio predefinido global. No-NULL = personalizado de ese usuario.
  user_id         uuid references auth.users (id) on delete cascade,
  nombre          text not null,
  -- Grupo muscular granular (cuadriceps, isquios, biceps, triceps, pecho...).
  -- Texto con valores controlados desde la app; sin enum para poder ampliar
  -- sin migración. Ver lista de referencia en el seed de abajo.
  grupo_muscular  text not null,
  created_at      timestamptz not null default now()
);

-- Un usuario no puede tener dos ejercicios personalizados con el mismo nombre.
-- (No afecta a los globales, donde user_id es NULL.)
create unique index exercises_user_nombre_idx
  on public.exercises (user_id, lower(nombre));

-- Búsqueda del catálogo por nombre (selector de ejercicio).
create index exercises_nombre_idx
  on public.exercises (lower(nombre));

-- ------------------------------------------------------------
-- 2. TABLA workouts  (una sesión de entreno con fecha)
-- ------------------------------------------------------------
-- Una fila por sesión entrenada. Puede nacer de una rutina (routine_id) o ser
-- entreno libre (routine_id NULL). Al instanciarse desde una rutina los
-- ejercicios se COPIAN a workout_sets (snapshot): editar la rutina más tarde
-- NO altera sesiones pasadas. El histórico es inmutable.
create table public.workouts (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  fecha       date not null default current_date,
  routine_id  bigint references public.routines (id) on delete set null,
  nombre      text not null,
  finalizado  boolean not null default false,
  duracion_s  integer,
  created_at  timestamptz not null default now()
);

create index workouts_user_fecha_idx
  on public.workouts (user_id, fecha desc);

-- ------------------------------------------------------------
-- 3. TABLA workout_sets  (un set real dentro de una sesión)
-- ------------------------------------------------------------
-- Una fila por SET ejecutado. Convive FK + snapshot:
--   · exercise_id  -> FK al catálogo. Da match FIABLE para la columna PREVIOUS
--     y para las stats por grupo muscular (no depende de cómo se escriba).
--   · nombre_ejercicio / grupo_muscular -> COPIA en texto en el momento de
--     registrar. Blinda el histórico: si el ejercicio del catálogo se borra o
--     renombra, el workout pasado conserva lo que se hizo.
-- on delete set null en exercise_id: borrar un ejercicio del catálogo no
-- destruye los sets pasados (se quedan con su copia de texto y exercise_id NULL).
create table public.workout_sets (
  id               bigint generated always as identity primary key,
  workout_id       bigint not null references public.workouts (id) on delete cascade,
  exercise_id      bigint references public.exercises (id) on delete set null,
  -- Snapshot de texto (ver nota arriba). Siempre presentes aunque exercise_id
  -- quede NULL en el futuro.
  nombre_ejercicio text not null,
  grupo_muscular   text not null,
  -- Posición del EJERCICIO dentro de la sesión (1 = primero...).
  orden_ejercicio  smallint not null default 1,
  -- Número de SET dentro del ejercicio (1, 2, 3...).
  num_set          smallint not null default 1,
  reps             integer,
  peso             numeric(6,2),
  completado       boolean not null default false,
  rpe              numeric(3,1)
);

create index workout_sets_workout_idx
  on public.workout_sets (workout_id, orden_ejercicio, num_set);

-- Para la columna PREVIOUS: último rendimiento de un ejercicio (por exercise_id).
create index workout_sets_exercise_idx
  on public.workout_sets (exercise_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.exercises     enable row level security;
alter table public.workouts      enable row level security;
alter table public.workout_sets  enable row level security;

-- ---- exercises ----
-- LECTURA: ve los globales (user_id NULL) y los propios.
create policy "exercises: ver globales y propios"
  on public.exercises for select
  using (user_id is null or auth.uid() = user_id);

-- ESCRITURA: el usuario solo crea/edita/borra ejercicios PROPIOS.
-- (Los globales se siembran con service_role, saltándose el RLS; un usuario
--  normal nunca puede tocar un ejercicio con user_id NULL.)
create policy "exercises: insertar propios"
  on public.exercises for insert
  with check (auth.uid() = user_id);

create policy "exercises: actualizar propios"
  on public.exercises for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "exercises: borrar propios"
  on public.exercises for delete
  using (auth.uid() = user_id);

-- ---- workouts ----
create policy "workouts: todo lo propio"
  on public.workouts for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---- workout_sets (propiedad vía el workout padre) ----
create policy "workout_sets: todo lo propio"
  on public.workout_sets for all
  using (
    exists (
      select 1 from public.workouts w
      where w.id = workout_sets.workout_id
        and w.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.workouts w
      where w.id = workout_sets.workout_id
        and w.user_id = auth.uid()
    )
  );

-- ============================================================
-- 4. SEED del catálogo de ejercicios predefinidos (user_id NULL)
-- ------------------------------------------------------------
-- ~90 ejercicios con grupo muscular granular. Se insertan como globales.
-- Grupos usados (referencia para la app):
--   pecho, espalda, dorsales, trapecio, hombro_anterior, hombro_lateral,
--   hombro_posterior, biceps, triceps, antebrazo, cuadriceps, isquios,
--   gluteo, gemelo, abductores, aductores, abdomen, lumbar, full_body.
-- ============================================================
insert into public.exercises (user_id, nombre, grupo_muscular) values
  -- ---- Pecho ----
  (null, 'Press banca con barra',            'pecho'),
  (null, 'Press banca con mancuernas',       'pecho'),
  (null, 'Press inclinado con barra',        'pecho'),
  (null, 'Press inclinado con mancuernas',   'pecho'),
  (null, 'Press declinado con barra',        'pecho'),
  (null, 'Aperturas con mancuernas',         'pecho'),
  (null, 'Aperturas en polea (cruces)',      'pecho'),
  (null, 'Pec deck (contractor)',            'pecho'),
  (null, 'Fondos en paralelas (pecho)',      'pecho'),
  (null, 'Press en máquina',                 'pecho'),
  (null, 'Flexiones',                        'pecho'),
  -- ---- Espalda / dorsales ----
  (null, 'Dominadas',                        'dorsales'),
  (null, 'Dominadas supinas (chin-up)',      'dorsales'),
  (null, 'Jalón al pecho',                   'dorsales'),
  (null, 'Jalón agarre cerrado',             'dorsales'),
  (null, 'Remo con barra',                   'espalda'),
  (null, 'Remo con mancuerna a una mano',    'espalda'),
  (null, 'Remo en polea baja',               'espalda'),
  (null, 'Remo en máquina',                  'espalda'),
  (null, 'Remo Pendlay',                     'espalda'),
  (null, 'Pullover con mancuerna',           'dorsales'),
  (null, 'Peso muerto convencional',         'espalda'),
  (null, 'Peso muerto rumano',               'isquios'),
  (null, 'Peso muerto sumo',                 'espalda'),
  (null, 'Hiperextensiones (lumbar)',        'lumbar'),
  (null, 'Buenos días (good morning)',       'lumbar'),
  -- ---- Trapecio ----
  (null, 'Encogimientos con barra',          'trapecio'),
  (null, 'Encogimientos con mancuernas',     'trapecio'),
  (null, 'Face pull',                        'hombro_posterior'),
  -- ---- Hombro ----
  (null, 'Press militar con barra',          'hombro_anterior'),
  (null, 'Press militar con mancuernas',     'hombro_anterior'),
  (null, 'Press Arnold',                     'hombro_anterior'),
  (null, 'Elevaciones laterales',            'hombro_lateral'),
  (null, 'Elevaciones laterales en polea',   'hombro_lateral'),
  (null, 'Elevaciones frontales',            'hombro_anterior'),
  (null, 'Pájaros (posterior con mancuernas)','hombro_posterior'),
  (null, 'Posterior en máquina (reverse pec)','hombro_posterior'),
  (null, 'Press hombro en máquina',          'hombro_anterior'),
  -- ---- Bíceps ----
  (null, 'Curl con barra',                   'biceps'),
  (null, 'Curl con barra Z',                 'biceps'),
  (null, 'Curl con mancuernas',              'biceps'),
  (null, 'Curl alterno',                     'biceps'),
  (null, 'Curl martillo',                    'biceps'),
  (null, 'Curl concentrado',                 'biceps'),
  (null, 'Curl predicador (Scott)',          'biceps'),
  (null, 'Curl en polea',                    'biceps'),
  (null, 'Curl araña',                       'biceps'),
  -- ---- Tríceps ----
  (null, 'Press francés',                    'triceps'),
  (null, 'Extensión en polea (cuerda)',      'triceps'),
  (null, 'Extensión en polea (barra)',       'triceps'),
  (null, 'Press cerrado con barra',          'triceps'),
  (null, 'Fondos en banco',                  'triceps'),
  (null, 'Fondos en paralelas (tríceps)',    'triceps'),
  (null, 'Patada de tríceps',                'triceps'),
  (null, 'Extensión sobre cabeza',           'triceps'),
  -- ---- Antebrazo ----
  (null, 'Curl de muñeca',                   'antebrazo'),
  (null, 'Curl de muñeca inverso',           'antebrazo'),
  (null, 'Paseo del granjero',               'antebrazo'),
  -- ---- Cuádriceps ----
  (null, 'Sentadilla con barra',             'cuadriceps'),
  (null, 'Sentadilla frontal',               'cuadriceps'),
  (null, 'Sentadilla goblet',                'cuadriceps'),
  (null, 'Prensa de piernas',                'cuadriceps'),
  (null, 'Extensión de cuádriceps',          'cuadriceps'),
  (null, 'Zancadas (lunges)',                'cuadriceps'),
  (null, 'Búlgaras',                         'cuadriceps'),
  (null, 'Hack squat',                       'cuadriceps'),
  (null, 'Sentadilla Sissy',                 'cuadriceps'),
  (null, 'Step ups',                         'cuadriceps'),
  -- ---- Isquios ----
  (null, 'Curl femoral tumbado',             'isquios'),
  (null, 'Curl femoral sentado',             'isquios'),
  (null, 'Peso muerto a una pierna',         'isquios'),
  (null, 'Nordic curl',                      'isquios'),
  -- ---- Glúteo ----
  (null, 'Hip thrust',                       'gluteo'),
  (null, 'Puente de glúteo',                 'gluteo'),
  (null, 'Patada de glúteo en polea',        'gluteo'),
  (null, 'Abducción en máquina',             'abductores'),
  (null, 'Aducción en máquina',              'aductores'),
  -- ---- Gemelo ----
  (null, 'Elevación de gemelos de pie',      'gemelo'),
  (null, 'Elevación de gemelos sentado',     'gemelo'),
  (null, 'Elevación de gemelos en prensa',   'gemelo'),
  -- ---- Abdomen / core ----
  (null, 'Crunch abdominal',                 'abdomen'),
  (null, 'Crunch en polea',                  'abdomen'),
  (null, 'Elevación de piernas colgado',     'abdomen'),
  (null, 'Elevación de rodillas',            'abdomen'),
  (null, 'Plancha',                          'abdomen'),
  (null, 'Rueda abdominal',                  'abdomen'),
  (null, 'Russian twist',                    'abdomen'),
  (null, 'Encogimiento en banco declinado',  'abdomen'),
  -- ---- Full body / olímpicos ----
  (null, 'Clean (cargada)',                  'full_body'),
  (null, 'Snatch (arrancada)',               'full_body'),
  (null, 'Thruster',                         'full_body'),
  (null, 'Kettlebell swing',                 'full_body'),
  (null, 'Burpees',                          'full_body');

-- ============================================================
-- NOTAS
-- ------------------------------------------------------------
-- · exercise_logs NO se elimina: queda para registro libre/rápido o futura
--   deprecación. No interfiere con esto.
-- · Columna PREVIOUS: buscar el set más reciente (workouts.fecha desc) del
--   usuario con un exercise_id dado. La FK da match fiable; el texto copiado
--   blinda el histórico.
-- · Grupo muscular sin enum a propósito: la app controla los valores, pero
--   poder añadir grupos nuevos sin migración es deseable.
-- · El seed usa user_id NULL (globales). Ejecutar este script desde el SQL
--   Editor lo corre como propietario (salta RLS), así que el INSERT de globales
--   funciona aunque la policy de INSERT exija auth.uid() = user_id.
-- ============================================================

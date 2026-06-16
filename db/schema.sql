-- ============================================================
-- gym-assistant — Esquema Bloque 1 (Supabase / Postgres)
-- Tablas + RLS + trigger de profiles
-- YA APLICADO en Supabase. Se guarda como referencia / por si hay
-- que recrear el proyecto. Pegar entero en SQL Editor y ejecutar una vez.
-- ============================================================

-- ------------------------------------------------------------
-- 1. TABLA profiles  (extiende auth.users)
-- ------------------------------------------------------------
create table public.profiles (
  id                    uuid primary key references auth.users (id) on delete cascade,
  nombre                text,
  objetivo_kcal_diario  integer default 2000,
  created_at            timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2. TABLA food_logs  (registros de comida)
-- ------------------------------------------------------------
create table public.food_logs (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  fecha        date not null default current_date,
  descripcion  text not null,
  kcal         integer,
  proteina     numeric(6,2),
  carbos       numeric(6,2),
  grasa        numeric(6,2),
  created_at   timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 3. TABLA exercise_logs  (registros sueltos de ejercicio)
-- ------------------------------------------------------------
create table public.exercise_logs (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  fecha       date not null default current_date,
  nombre      text not null,
  series      integer,
  reps        integer,
  peso        numeric(6,2),
  created_at  timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 4. TABLA routines  (rutinas del usuario)
-- ------------------------------------------------------------
create table public.routines (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  nombre     text not null,
  created_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 5. TABLA routine_exercises  (ejercicios dentro de una rutina)
-- ------------------------------------------------------------
create table public.routine_exercises (
  id               bigint generated always as identity primary key,
  routine_id       bigint not null references public.routines (id) on delete cascade,
  dia_semana       smallint,           -- 1 = lunes ... 7 = domingo
  nombre_ejercicio text not null,
  orden            smallint,
  series           integer,
  reps             integer,
  pct_carga        numeric(5,2)        -- % de carga (ej. 75.00)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.profiles          enable row level security;
alter table public.food_logs         enable row level security;
alter table public.exercise_logs     enable row level security;
alter table public.routines          enable row level security;
alter table public.routine_exercises enable row level security;

-- ---- profiles ----
create policy "profiles: select propio"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: update propio"
  on public.profiles for update
  using (auth.uid() = id);

-- ---- food_logs ----
create policy "food_logs: todo lo propio"
  on public.food_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---- exercise_logs ----
create policy "exercise_logs: todo lo propio"
  on public.exercise_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---- routines ----
create policy "routines: todo lo propio"
  on public.routines for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---- routine_exercises (validado vía rutina padre) ----
create policy "routine_exercises: todo lo propio"
  on public.routine_exercises for all
  using (
    exists (
      select 1 from public.routines r
      where r.id = routine_exercises.routine_id
        and r.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.routines r
      where r.id = routine_exercises.routine_id
        and r.user_id = auth.uid()
    )
  );

-- ============================================================
-- TRIGGER: crear fila en profiles al registrarse un usuario
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nombre)
  values (new.id, new.raw_user_meta_data ->> 'nombre');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

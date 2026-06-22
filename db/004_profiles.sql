-- ============================================================
-- gym-assistant — Migración 004: Perfil (plan + antropometría + protección)
-- Amplía public.profiles para cerrar el free a lo ancho (pantalla Perfil):
--   · plan (free/pro): base del modelo de negocio. Pagos NO se implementan aún;
--     solo el campo y su protección.
--   · Campos antropométricos: informativos/editables a mano en free. En pro
--     alimentarán el cálculo del objetivo (Mifflin-St Jeor). Todos nullable.
--   · Trigger que impide al usuario auto-editar su plan (solo service_role,
--     que vive en n8n, puede promover a pro).
--
-- IDEMPOTENTE a propósito: usa IF NOT EXISTS / DROP IF EXISTS para poder
-- reejecutarse sobre una BD donde esto ya está aplicado, sin error.
-- Pegar en el SQL Editor de Supabase y ejecutar.
--
-- Nota: objetivo_kcal_diario ya existía desde el esquema Bloque 1 (default 2000),
-- no se toca aquí; solo se documenta que Perfil lo edita.
-- ============================================================

-- ------------------------------------------------------------
-- 1. plan (free/pro)
-- ------------------------------------------------------------
-- not null + default 'free': todo usuario nace en free. El CHECK acota valores.
alter table public.profiles
  add column if not exists plan text not null default 'free';

alter table public.profiles
  drop constraint if exists profiles_plan_check;
alter table public.profiles
  add constraint profiles_plan_check
  check (plan in ('free', 'pro'));

-- ------------------------------------------------------------
-- 2. Campos antropométricos (todos nullable)
-- ------------------------------------------------------------
-- Informativos en free; el usuario los rellena cuando quiere. En pro serán el
-- input del cálculo del objetivo. Se guarda fecha_nacimiento (no la edad): la
-- edad se deriva en la app al renderizar y nunca caduca.
alter table public.profiles add column if not exists sexo             text;
alter table public.profiles add column if not exists fecha_nacimiento date;
alter table public.profiles add column if not exists altura_cm        smallint;
alter table public.profiles add column if not exists peso_kg          numeric(5,2);
alter table public.profiles add column if not exists nivel_actividad  text;
alter table public.profiles add column if not exists objetivo         text;

-- CHECKs de valores controlados y rangos sensatos. Se recrean por idempotencia.
-- La app debe ofrecer EXACTAMENTE estos valores (en español) o el insert/update
-- será rechazado.
alter table public.profiles drop constraint if exists profiles_sexo_check;
alter table public.profiles add constraint profiles_sexo_check
  check (sexo in ('hombre', 'mujer'));

alter table public.profiles drop constraint if exists profiles_altura_check;
alter table public.profiles add constraint profiles_altura_check
  check (altura_cm between 80 and 260);

alter table public.profiles drop constraint if exists profiles_peso_check;
alter table public.profiles add constraint profiles_peso_check
  check (peso_kg between 25 and 400);

alter table public.profiles drop constraint if exists profiles_nivel_check;
alter table public.profiles add constraint profiles_nivel_check
  check (nivel_actividad in ('sedentario', 'ligero', 'moderado', 'activo', 'muy_activo'));

alter table public.profiles drop constraint if exists profiles_objetivo_check;
alter table public.profiles add constraint profiles_objetivo_check
  check (objetivo in ('perder', 'mantener', 'ganar'));

-- ------------------------------------------------------------
-- 3. Protección de plan contra auto-edición
-- ------------------------------------------------------------
-- La policy "profiles: update propio" deja al usuario hacer UPDATE de su fila
-- (necesario para editar objetivo_kcal_diario y los datos antropométricos), pero
-- sin esto podría ponerse plan='pro' a mano. El trigger revierte cualquier
-- cambio de plan SALVO que venga de service_role (n8n), que sí podrá promover a
-- pro cuando llegue la capa de pagos.
create or replace function public.prevent_plan_self_edit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.plan is distinct from old.plan
     and auth.role() <> 'service_role' then
    new.plan := old.plan;
  end if;
  return new;
end;
$$;

drop trigger if exists lock_plan on public.profiles;
create trigger lock_plan
  before update on public.profiles
  for each row execute function public.prevent_plan_self_edit();

-- ============================================================
-- Estado final de public.profiles tras esta migración:
--   id                    uuid    (PK, = auth.users.id)
--   nombre                text    nullable
--   objetivo_kcal_diario  integer default 2000  (editable por el usuario)
--   created_at            timestamptz not null default now()
--   plan                  text    not null default 'free'  (free|pro, read-only user)
--   sexo                  text    nullable  (hombre|mujer)
--   fecha_nacimiento      date    nullable
--   altura_cm             smallint nullable (80-260)
--   peso_kg               numeric(5,2) nullable (25-400)
--   nivel_actividad       text    nullable (sedentario|ligero|moderado|activo|muy_activo)
--   objetivo              text    nullable (perder|mantener|ganar)
--
-- RLS (del esquema Bloque 1) sigue vigente, no se toca:
--   · "profiles: select propio"  -> auth.uid() = id
--   · "profiles: update propio"  -> auth.uid() = id
-- Trigger handle_new_user (Bloque 1) sigue creando la fila al registrarse.
--
-- La app NUNCA debe enviar `plan` en un UPDATE desde el cliente: el trigger lo
-- revertiría. plan se lee y se muestra, no se escribe desde Flutter.
-- ============================================================
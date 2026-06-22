-- ============================================================
-- gym-assistant — Migración 005: objetivo_kcal_diario sin DEFAULT
-- Quita el DEFAULT 2000 de profiles.objetivo_kcal_diario para que las filas
-- NUEVAS nazcan con NULL ("objetivo sin fijar"), distinguible de un 2000 elegido
-- a propósito por el usuario. Esa distinción la necesita la pantalla Inicio
-- (ver specs/006_inicio.md §5) para mostrar un estado vacío que invita a fijarlo.
--
-- DECISIÓN: NO se tocan las filas existentes. Las que hoy tienen 2000 pudieron
-- fijarlo a propósito; no sabemos distinguirlo, así que se respetan tal cual.
-- La columna sigue siendo nullable (ya lo era). No existe CHECK de rango sobre
-- esta columna (ni en schema.sql ni en 004), así que no hay nada que preservar.
--
-- IDEMPOTENTE: "drop default" sobre una columna sin default es un no-op sin error,
-- de modo que la migración puede reejecutarse sin problema.
-- Pegar en el SQL Editor de Supabase y ejecutar.
-- ============================================================

alter table public.profiles
  alter column objetivo_kcal_diario drop default;

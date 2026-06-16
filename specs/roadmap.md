# Roadmap — gym-assistant

Fases del MVP y más allá. La arquitectura (ver `specs/architecture.md`) y el
esquema (ver `specs/database.md`) ya están diseñados para soportar TODAS estas
fases sin rehacer nada. No sobre-construir: cada fase añade lo justo.

## Estado actual
- [x] Bloque 0 — Entorno: Supabase, n8n (Docker) y proyecto Flutter creados.
- [x] Bloque 1 — Base de datos: tablas + RLS + trigger de profiles aplicados.
- [ ] Bloque 2 — Auth en Flutter (EN CURSO): login, registro, logout y gestión
      de sesión reactiva.

## Fase 1 — Comidas por texto + barra de progreso
Es el hito que valida toda la arquitectura (front → n8n → DB → front).
- Workflow n8n "registrar comida": webhook recibe POST → INSERT en `food_logs` →
  responde confirmación.
- Pantalla Comidas en Flutter: campo de texto + botón registrar (POST al webhook).
- Barra de progreso: lectura DIRECTA de Supabase (SUM de kcal de hoy del usuario
  contra `objetivo_kcal_diario`). No pasa por n8n.
- Lista de comidas de hoy debajo.

## Fase 2 — Ejercicio manual
Mismo patrón que comidas, ya rodado.
- Pantalla Ejercicio: formulario (nombre, series, reps, peso) + botón.
- Registrar → webhook n8n "registrar ejercicio" → INSERT en `exercise_logs`.
- Vista: lista de ejercicios agrupados por fecha.

## Fase 3 — Visión (estimación de macros)
La IA de visión rellena los macros de `food_logs` (proteína, carbos, grasa, kcal)
a partir de una foto o descripción. Se enchufa en el workflow de n8n de comidas.

## Fase 5 — Agente
Un agente rellena rutinas (`routines` / `routine_exercises`) y automatiza registro.
Por eso esas tablas ya existen aunque el MVP no las use todavía.

## Principios
- Sin estilo elaborado hasta que el flujo funcione.
- Escribir pasa por n8n; leer directo de Supabase.
- No tocar el esquema: ya contempla las fases futuras.

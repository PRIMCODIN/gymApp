# Arquitectura — gym-assistant

## Visión general
Tres componentes que se comunican entre sí:

```
┌──────────┐        escribir         ┌──────────┐      ┌────────────┐
│  Flutter │ ──────────────────────► │   n8n    │ ───► │  Supabase  │
│  (app/)  │ ◄───────────  leer  ─────────────────────│ (Postgres) │
└──────────┘                          └──────────┘      └────────────┘
```

## Principio clave: escribir vs leer
- **ESCRIBIR pasa por n8n.** Registrar una comida o un ejercicio se hace mediante
  un POST a un webhook de n8n, que inserta en Supabase. ¿Por qué? Porque ese punto
  es donde en fases futuras se enchufa la IA (clasificación de intención, visión
  para estimar macros, agente). Dejar la escritura en n8n desde el principio evita
  rehacer el flujo después.
- **LEER se hace directo de Flutter a Supabase.** Consultas como "calorías de hoy"
  o "lista de comidas" se hacen con el cliente `supabase_flutter` directamente,
  sin pasar por n8n. Es más simple y rápido, y no necesita lógica intermedia.

Esta distinción (escribir orquestado, leer directo) es una decisión de diseño
deliberada y demuestra criterio: no todo tiene que pasar por el orquestador.

## Seguridad
- Toda tabla tiene Row Level Security (RLS) activado. Cada usuario solo accede a
  sus propias filas (`auth.uid() = user_id`). La seguridad está garantizada a
  nivel de base de datos, no de aplicación.
- Flutter usa SOLO la clave pública (anon / publishable), segura en cliente porque
  el RLS protege los datos.
- n8n usa la clave privilegiada (service_role / secret), que salta el RLS para
  poder insertar. Esa clave vive cifrada dentro de n8n y nunca sale de ahí.

## Componentes
- **Flutter (`app/`):** UI, autenticación de usuario, lectura directa de datos,
  y envío de registros a los webhooks de n8n.
- **n8n (`infra/`):** workflows que reciben webhooks y escriben en Supabase. En
  desarrollo corre en local con Docker. Para pruebas en móvil físico se expondrá
  el webhook (VPS o túnel), porque el móvil no ve el localhost del PC.
- **Supabase:** Postgres con Auth y API. Fuente de verdad de los datos.

## Roadmap de fases
Ver `specs/roadmap.md`. La arquitectura está diseñada para soportar todas las
fases sin rehacer el esquema ni el flujo de datos.

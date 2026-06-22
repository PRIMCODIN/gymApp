# Spec — Pantalla Inicio (dashboard)

> Estado: borrador para implementar. Última pantalla free a lo ancho.
> Convenciones globales en `CLAUDE.md` y specs previas. Esta spec **manda** sobre suposiciones.

## 1. Propósito

Inicio es el **hub** de la app: el punto de aterrizaje tras login. No es una pantalla de captura ni de análisis profundo; es un panel que (a) da una foto rápida del día, (b) lanza las dos acciones de alta frecuencia, y (c) enruta a Nutrición y Entreno. La profundidad vive en sus pantallas; aquí solo se resume y se navega.

Principio rector: **una sola pasada de ojos basta para saber cómo va el día y qué hacer ahora.**

## 2. Alcance

### Entra (free)
- Saludo + fecha de hoy.
- Mini-resumen de **Nutrición** del día (consumido vs objetivo + macros).
- Mini-resumen de **Entreno** (último entreno + racha semanal).
- Dos acciones rápidas: **Empezar/continuar entreno** y **Registrar comida**.

### No entra
- Edición de cualquier dato (todo es read-only + navegación).
- Cálculo automático de objetivo (es pro; aquí solo se consume `objetivo_kcal_diario` tal cual).
- Gráficas históricas / tendencias.
- Personalización del dashboard (orden de tarjetas, widgets).

## 3. Estructura (de arriba a abajo)

```
┌─────────────────────────────────────┐
│  Cabecera: saludo + fecha            │
├─────────────────────────────────────┤
│  Tarjeta Nutrición (acento naranja)  │  → tap navega a Nutrición (hoy)
│   · anillo/barra kcal restantes      │
│   · macros P/C/G                     │
│   · estado vacío si objetivo null    │
├─────────────────────────────────────┤
│  Tarjeta Entreno (acento teal)       │  → tap navega a Historial/Entreno
│   · último entreno (nombre + fecha)  │
│   · racha semanal                    │
├─────────────────────────────────────┤
│  Acciones rápidas (2 botones)        │
│   [ Empezar/continuar entreno ]      │
│   [ Registrar comida ]               │
└─────────────────────────────────────┘
```

Orden fijo. Nutrición primero porque es el dato que más cambia a lo largo del día.

## 4. Cabecera

- Saludo simple dependiente de la hora local del dispositivo: `Buenos días` (<12), `Buenas tardes` (12–20), `Buenas noches` (≥20).
- Nombre: el mismo que Perfil (`nombre`, con fallback a inicial de email si null). Reutiliza la fuente, no dupliques lógica de fallback — extráela a un helper compartido si aún vive dentro de Perfil.
- Segunda línea: fecha de hoy formateada en español (`lunes, 22 de junio`). `intl` con locale `es`.

## 5. Tarjeta Nutrición

Reutiliza `DailyTotals` de Nutrición (no recalcular). Fuente del objetivo: `objetivo_kcal_diario` del perfil (mismo provider que ya invalida Perfil al editarlo: `dailyCalorieGoalProvider`).

### Caso con objetivo (no null)
- Indicador principal: **kcal restantes** = `objetivo - consumido`. Si negativo, mostrar excedido (texto en color de error/aviso del theme, sin alarmismo).
- Representación: **anillo** de progreso `consumido / objetivo` como principal; barra como fallback MVP si el anillo se complica. Todos los colores/tamaños del theme (acento naranja nutrición).
- Macros del día: P / C / G en gramos (de `DailyTotals`). Sin objetivos de macro en free — solo consumido.
- Tap en la tarjeta → Nutrición del día de hoy.

### Caso objetivo null (decisión cerrada)
- **Estado vacío que invita a fijarlo en Perfil.** No mostrar anillo ni "restantes" (no hay denominador).
- Mostrar consumido del día (eso sí se conoce) + un CTA discreto: texto tipo «Fija tu objetivo de calorías en Perfil» que navega a Perfil.
- No bloquear la tarjeta entera: el consumido + macros siguen siendo útiles aunque no haya objetivo.

## 6. Tarjeta Entreno

Lectura agregada read-only (mismo patrón estrenado en Perfil). Repositorio de entreno, no el de perfil.

- **Último entreno**: nombre de la rutina/sesión + fecha relativa (`hoy`, `ayer`, `hace 3 días`). Solo sesiones con `finalizado = true` (mismo filtro que stats de Perfil — cuidado con el riesgo de desajuste ya anotado).
- **Racha semanal**: reutiliza la función pura `currentStreak`. Muestra el número de semanas + etiqueta (ej. «3 semanas»). Misma regla: ≥3 sesiones finalizadas/semana ISO.
- Estado vacío: sin entrenos finalizados todavía → texto neutro («Aún no has registrado entrenos») en vez de campos vacíos.
- Tap → **Historial de Entreno** (calendario), donde el último entreno y la racha cobran contexto. El arranque de sesión NO va aquí: vive en el botón de acción rápida. Regla: tarjeta = ver el dominio en profundidad, botón = hacer.

## 7. Acciones rápidas

Dos botones, jerarquía visual clara (no compiten con las tarjetas).

1. **Empezar/continuar entreno** (acento teal).
   - Si hay sesión activa en curso → etiqueta «Continuar entreno» y navega a esa sesión.
   - Si no → «Empezar entreno» y navega al flujo de inicio de sesión/selección de rutina.
   - La detección de sesión activa: reutilizar el estado que ya gobierna las sesiones activas en Entreno; no inventar fuente nueva.
2. **Registrar comida** (acento naranja).
   - Navega al flujo de registro de comida de Nutrición para hoy.

## 8. Estados de pantalla

- **Carga**: skeleton/placeholders por tarjeta (no un spinner global que bloquee toda la pantalla). Cada tarjeta resuelve su propio async.
- **Error por tarjeta**: si falla la lectura de una tarjeta, esa tarjeta muestra estado de error con reintento; las demás siguen vivas. Inicio nunca queda en blanco por un fallo parcial.
- **Vacío total** (usuario nuevo sin datos): nutrición sin registros + sin entrenos + objetivo null → ambas tarjetas en su estado vacío, acciones rápidas siempre presentes y operativas. Inicio debe seguir siendo accionable el día 1.
- **Refresco**: pull-to-refresh que invalida los providers de las tarjetas. Al volver de registrar comida o de un entreno, los datos deben reflejarse en caliente (invalidación de providers, igual que el sync objetivo↔Nutrición de Perfil).

## 9. Datos y providers (resumen)

| Dato | Fuente | Notas |
|---|---|---|
| nombre / email | perfil (Auth + tabla) | helper de fallback compartido con Perfil |
| objetivo kcal | `dailyCalorieGoalProvider` | nullable → dispara estado vacío |
| consumido + macros | `DailyTotals` (Nutrición) | reutilizar, no recalcular |
| último entreno | repo entreno, `finalizado = true` | fecha relativa |
| racha | `currentStreak(...)` | función pura existente |
| sesión activa | estado de sesiones de Entreno | gobierna etiqueta del botón |

## 10. Convenciones aplicables (recordatorio)

- Dark-only. Cero hex/tamaños sueltos: todo del theme. Teal `#2DD4BF` = entreno, naranja `#F97316` = nutrición, Inter.
- UI en español, código en inglés. Enums en español en BD, traducción a etiqueta en UI.
- `flutter analyze` limpio antes de cerrar.
- Sin tests salvo función pura (aquí no se introduce ninguna nueva; `currentStreak` ya tiene los suyos).

## 11. Orden de build sugerido

1. Esqueleto de pantalla + cabecera (saludo + fecha) — sin datos async.
2. Tarjeta Entreno (lecturas ya disponibles: último entreno + racha).
3. Tarjeta Nutrición caso con objetivo (anillo/barra + macros).
4. Tarjeta Nutrición caso null (estado vacío + CTA a Perfil).
5. Acciones rápidas + lógica empezar/continuar.
6. Estados de carga/error/vacío por tarjeta + pull-to-refresh.
7. Cuadre visual y `flutter analyze`.

## 12. Pendiente de decidir en implementación (no bloqueante)

- Si la fecha relativa del último entreno necesita un helper propio o ya existe uno en el proyecto.
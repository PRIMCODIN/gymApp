# Design System — gym-assistant

Fuente de verdad de la identidad visual. Estos tokens deben implementarse en un
**theme central de Flutter** (`app/lib/core/theme/`) y consumirse SIEMPRE desde ahí.
Ninguna pantalla debe usar valores hex o tamaños sueltos: todo sale del theme.

## Concepto
Estilo minimalista y limpio sobre base oscura (inspiración: Hevy). Dos acentos
semánticos: uno frío para **entrenamiento**, uno cálido para **nutrición**.
La mayoría de la pantalla es escala de grises; el color solo marca lo accionable
o el progreso.

---

## Tokens de color

### Acentos semánticos
| Token                | Hex       | Uso |
|----------------------|-----------|-----|
| `accentTraining`     | `#2DD4BF` | Teal. Acento principal de entreno: botones de entreno, series/reps activas, progreso de ejercicio. |
| `accentTrainingDeep` | `#0D9488` | Teal profundo. Fondos o estados activos de entreno. |
| `accentNutrition`    | `#F97316` | Zanahoria (naranja vivo). Acento principal de nutrición: barras de calorías, macros, registro de comidas. |
| `accentNutritionSoft`| `#FB923C` | Naranja suave. Texto/iconos pequeños que necesiten luminosidad sobre oscuro. |

### Neutros / fondos (modo oscuro)
| Token            | Hex       | Uso |
|------------------|-----------|-----|
| `background`     | `#0F1115` | Fondo base (gris muy oscuro, no negro puro). |
| `surface`        | `#1A1D23` | Superficie / tarjetas. |
| `surfaceElevated`| `#252931` | Superficie elevada / inputs. |
| `divider`        | `#2E323B` | Separadores sutiles (sin líneas duras). |
| `textPrimary`    | `#F5F6F7` | Texto principal. |
| `textSecondary`  | `#9CA3AF` | Texto secundario / etiquetas. |

> Nota: los hex son un punto de partida sólido. Pueden ajustarse finos al ver los
> componentes juntos, pero el cambio se hace SIEMPRE en el token, nunca en pantalla.

---

## Reglas de uso del color (la "regla de oro")
- **Teal y zanahoria no compiten.** El teal vive en el contexto de entreno; el
  naranja en el de nutrición.
- En pantallas mixtas (ej. resumen del día), cada métrica lleva su color para que
  el usuario se oriente al instante (calorías en naranja, entreno en teal).
- El color marca solo lo **accionable** o el **progreso**. El resto, escala de grises.
- Disciplina: si una pantalla parece un arcoíris, algo se está usando mal.

---

## Tipografía
- Familia: sans-serif moderna y neutra (tipo **Inter**, **Geist** o similar).
- **La jerarquía se marca por peso y tamaño, NO por color.**
- Los **números son protagonistas** (peso, reps, calorías): grandes y bold, deben
  leerse de un vistazo.
- Etiquetas: gris tenue (`textSecondary`), pequeñas, en mayúsculas o regular.

### Tokens tipográficos (definir tamaños exactos al implementar el theme)
| Token          | Uso                                            |
|----------------|------------------------------------------------|
| `displayLarge` | Dato clave protagonista (kcal del día, peso). Grande + bold. |
| `headingMedium`| Títulos de sección / pantalla.                 |
| `bodyMedium`   | Texto normal de contenido.                     |
| `labelSmall`   | Etiquetas tenues, mayúsculas, `textSecondary`. |

---

## Espaciado
Escala de espaciados base (definir valores al implementar; sugerencia de partida):
| Token       | Sugerencia |
|-------------|------------|
| `spacingXS` | 4  |
| `spacingS`  | 8  |
| `spacingM`  | 16 |
| `spacingL`  | 24 |
| `spacingXL` | 32 |

Generosidad: mucho espacio entre elementos. El minimalismo se apoya en el aire.

---

## Forma y elevación
- **Radio de esquinas:** generoso, ~`16px` para tarjetas (token `radiusCard`).
- Tarjetas sobre `surface`, inputs sobre `surfaceElevated`.
- Separadores con `divider`, sutiles, nunca líneas duras.
- Sombras discretas (el contraste lo da el escalón de gris, no sombras marcadas).

---

## Componentes base (a crear en `core/`)
Componentes reutilizables que toda pantalla debe usar (no reinventar por pantalla):

- **`AppButton`** — botón principal. Variantes:
  - `training` (fondo/acento `accentTraining`)
  - `nutrition` (fondo/acento `accentNutrition`)
  - `neutral` / secundario (sobre `surfaceElevated`)
- **`AppTextField`** — input sobre `surfaceElevated`, con label tenue y manejo de
  estado de error.
- **`AppCard`** — tarjeta sobre `surface`, radio `radiusCard`, padding `spacingM`.
- **`AppProgressBar`** — barra de progreso, con color según contexto (naranja para
  calorías, teal para entreno).
- **Iconografía:** línea fina y consistente (un único set de iconos).
- **Navegación inferior:** simple.

---

## Implementación (importante)
1. Este `.md` es la fuente de verdad **conceptual**.
2. Debe materializarse en un theme de Flutter en `core/theme/` (colores, text
   styles, spacing, shapes) como constantes/`ThemeData`.
3. TODA pantalla y componente consume del theme. Prohibido hex o tamaños sueltos
   en widgets de pantalla.
4. Cambiar un color o tamaño = cambiar el token en el theme, y toda la app se
   actualiza. Ese es el objetivo de centralizarlo.
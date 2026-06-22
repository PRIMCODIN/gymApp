# Pantalla: Perfil

Última de las pantallas free. Cierra el free "a lo ancho" junto con Inicio.
Identidad mínima del usuario + objetivo de kcal editable + datos antropométricos
(informativos en free) + acceso a cerrar sesión. Aquí colgará más adelante el
hook de upgrade a pro.

## Propósito y alcance

- **Free (esta spec):** los datos antropométricos son **informativos y editables a
  mano**. No se calcula nada a partir de ellos. `objetivo_kcal_diario` es un número
  que el usuario edita libremente (arranca en 2000, default de BD).
- **Pro (fuera de alcance, no implementar):** esos mismos campos alimentarán el
  cálculo del objetivo (Mifflin-St Jeor → TDEE → ajuste por objetivo). La UI no
  cambiará; solo se le enchufará la lógica. No añadir nada de cálculo ahora.

## Origen de datos

Toda la pantalla lee y escribe **directo Flutter→Supabase** sobre la tabla
`profiles` (lectura/guardado simple, sin IA, sin n8n). RLS ya vigente: el usuario
solo ve y edita su propia fila (`auth.uid() = id`).

### Tabla `profiles` (columnas relevantes, ya existentes en BD)

| Columna                | Tipo          | Notas                                                              |
| ---------------------- | ------------- | ------------------------------------------------------------------ |
| `id`                   | uuid          | PK, = auth.users.id                                                |
| `nombre`               | text          | nullable                                                           |
| `objetivo_kcal_diario` | integer       | default 2000. **Editable** por el usuario.                         |
| `plan`                 | text          | `'free'` \| `'pro'`. default `'free'`. **Read-only** para el user. |
| `sexo`                 | text          | `'hombre'` \| `'mujer'`. nullable.                                 |
| `fecha_nacimiento`     | date          | nullable. **Se guarda la fecha**, no la edad.                      |
| `altura_cm`            | smallint      | 80–260. nullable.                                                  |
| `peso_kg`              | numeric(5,2)  | 25–400. nullable.                                                  |
| `nivel_actividad`      | text          | `sedentario`\|`ligero`\|`moderado`\|`activo`\|`muy_activo`. nullable. |
| `objetivo`             | text          | `perder`\|`mantener`\|`ganar`. nullable.                          |

Los valores controlados tienen `CHECK` en BD; la app debe ofrecer **exactamente**
esos valores (no inventar otros) o el insert/update fallará.

### Protección de `plan`

El trigger `lock_plan` (función `prevent_plan_self_edit`) revierte cualquier
cambio de `plan` salvo que venga de `service_role`. Consecuencia para la app:
**nunca** enviar `plan` en un UPDATE desde Flutter (se revertiría igualmente).
`plan` se lee y se muestra, nunca se escribe desde el cliente.

## Estructura de la pantalla (de arriba a abajo)

1. **Cabecera**
   - Avatar circular con iniciales derivadas de `nombre` (si `nombre` es null,
     fallback a inicial del email).
   - `nombre` + email (email desde la sesión de Supabase Auth, no de `profiles`).
   - Badge de `plan` a la derecha: "Free" / "Pro". Read-only. Estilado con el
     color de su dominio (naranja sobre fondo tenue). Es el futuro punto de
     entrada al upgrade (en pro será tappable; ahora solo muestra).

2. **Bloque "Objetivo"**
   - Tarjeta con `objetivo_kcal_diario` en grande (acento naranja, dominio
     nutrición), unidad "kcal", e icono de edición.
   - Editable: tap abre un editor (campo numérico) que guarda el nuevo valor.
   - Sin texto de "calculado desde tus datos" (eso es pro).

3. **Bloque "Tus datos"**
   - Lista de seis filas etiqueta→valor: Sexo, Edad, Altura, Peso, Nivel
     actividad, Objetivo.
   - **Edad** se muestra calculada desde `fecha_nacimiento` en el momento de
     render (no se almacena). Si `fecha_nacimiento` es null, fila vacía.
   - Cualquier campo null se muestra como placeholder tenue ("Añadir") en vez de
     un valor. Por defecto, usuario nuevo = los seis vacíos.
   - Tap en "Editar mis datos" abre un formulario para rellenar/editar los seis.

4. **Editar mis datos** (botón) → formulario de edición de los seis campos.

5. **Cerrar sesión** (botón, estilo destructivo/rojo) → `supabase.auth.signOut()`
   y navegación a la pantalla de Auth. Reutiliza el flujo de Auth existente.

## Formulario "Editar mis datos"

Un solo formulario con los seis campos. Tipos de control:

- **Sexo:** selector de dos opciones (Hombre / Mujer).
- **Fecha de nacimiento:** date picker. Guardar como `date`.
- **Altura (cm):** numérico entero. Validar 80–260 antes de enviar.
- **Peso (kg):** numérico decimal (1 decimal suficiente en UI). Validar 25–400.
- **Nivel de actividad:** selector con las cinco opciones (etiquetas en español
  legibles, valor en español de BD: `sedentario`…`muy_activo`).
- **Objetivo:** selector de tres (Perder / Mantener / Ganar → `perder`/`mantener`/`ganar`).

Todos opcionales (se puede guardar con campos vacíos → null). Validar rangos en
cliente para dar feedback antes de que el CHECK de BD rechace.

## Estados

- **Carga:** placeholder mientras se lee `profiles`.
- **Vacío (usuario nuevo):** objetivo = 2000 (default), seis datos vacíos con
  "Añadir". Es un estado válido, no un error.
- **Error de lectura/guardado:** mensaje breve, opción de reintentar. No romper la
  pantalla.

## Mapeo BD ↔ Dart

BD en español por coherencia con el resto del esquema. En Dart, los nombres de
campo del modelo van en **inglés** (regla del proyecto: código en inglés, UI en
español). El mapeo vive en la capa de datos (data layer), p.ej.:

| Dart (modelo)      | Columna BD             |
| ------------------ | ---------------------- |
| `kcalGoal`         | `objetivo_kcal_diario` |
| `plan`             | `plan`                 |
| `sex`              | `sexo`                 |
| `birthDate`        | `fecha_nacimiento`     |
| `heightCm`         | `altura_cm`            |
| `weightKg`         | `peso_kg`              |
| `activityLevel`    | `nivel_actividad`      |
| `goal`             | `objetivo`             |

Los **valores** de enums de texto se mantienen en español tal cual están en BD
(`'hombre'`, `'sedentario'`, `'perder'`…), porque son lo que el CHECK valida. La
UI traduce a etiquetas legibles; el valor almacenado no se traduce.

## Reglas de diseño (recordatorio, del design system)

- Dark-only. Nada de hex/tamaños sueltos: todo desde el theme.
- Naranja (`#F97316`) = nutrición → objetivo de kcal y badge de plan.
- Teal (`#2DD4BF`) = entreno → reservado para el bloque de stats (concern aparte,
  no en esta spec).
- Fuente Inter (asset). UI en español, código en inglés.

## Fuera de alcance de esta spec (concerns separados)

- **Stats agregadas** (entrenos total / este mes / racha): bloque teal, lecturas
  read-only sobre `workouts`. Se especifica aparte.
- **Cálculo automático del objetivo** (Mifflin-St Jeor): feature pro.
- **Pantalla Inicio** (dashboard): spec propia; consumirá `objetivo_kcal_diario`.

## Criterio de cierre

- `flutter analyze` limpio.
- Leer perfil, editar `objetivo_kcal_diario`, editar los seis datos (incluido
  dejarlos vacíos), ver `plan` sin poder editarlo, cerrar sesión.
- Ningún UPDATE incluye `plan`.
- Valores de enum enviados a BD coinciden con los CHECK (en español).
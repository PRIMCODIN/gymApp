# Product Roadmap — gym-assistant

Roadmap de **madurez de producto**, en paralelo al de funcionalidad
(`specs/roadmap.md`). Mientras `roadmap.md` dice QUÉ features se construyen,
este documento dice qué hace falta para que la app sea **profesional y lanzable**.

> Principio rector: no se trata de hacer todas las fases ahora. Se trata de tomar
> hoy decisiones que no haya que deshacer mañana. No sobre-construir: cada capa
> entra en su momento.

---

## Estado de madurez actual
- [x] RLS activado en toda la base de datos (seguridad a nivel de fila).
- [x] Secretos fuera del repositorio (`env.json`, `.env` en `.gitignore`).
- [x] Arquitectura por capas definida (Clean Architecture + Riverpod).
- [x] Auth básica funcionando (login / registro / logout / sesión reactiva).
- [ ] Control de versiones en remoto (git + GitHub).  ← SIGUIENTE
- [ ] Auth completa (confirmación email, reset password, validaciones).

---

## Fase M0 — Higiene básica (AHORA, antes de más features)

Deuda que se paga barata ahora y cara después.

### M0.1 — Git + GitHub (innegociable, primero de todo)
- `git init` en la raíz `gym-assistant/`, primer commit.
- Verificar que `.gitignore` bloquea `app/env.json` e `infra/.env` ANTES del
  primer push.
- A partir de aquí: commits pequeños por unidad de trabajo coherente.
- Es la red de seguridad de todo lo demás (lección aprendida al cambiar de PC).

### M0.2 — Cerrar el Bloque 2 de Auth del todo
Lo que hay funciona, pero "profesional" implica el flujo completo:
- Confirmación por email al registrarse (necesario para lanzar; evita cuentas
  basura). Configurable en Supabase Auth.
- Recuperación de contraseña (reset por email).
- Validación de inputs: formato de email, contraseña con mínimo de seguridad.
- Mensajes de error claros para cada caso (ya iniciado).

---

## Fase M1 — Sistema de diseño (EN PARALELO, desde pronto)

> Ver sección "UI: cuándo y cómo" al final. Esto NO es pulir pantallas; es
> centralizar el diseño para no repetir estilos a mano.

- **Theme central** de Flutter en `core/`: paleta de colores, tipografía,
  espaciados base. Un único sitio donde se define el look.
- **Componentes reutilizables** básicos en `core/` (ej. `AppButton`,
  `AppTextField`, `AppCard`). Aunque sean simples al principio.
- Objetivo: cambiar el color primario en UN sitio y que toda la app se actualice.
- Se puede empezar YA en paralelo al diseño, porque no depende de la lógica.

---

## Fase M2 — Núcleo funcional como plantilla de calidad

Coincide con Fase 1-2 de `roadmap.md` (comidas y ejercicio), pero con criterio:
- La PRIMERA feature (comidas) se hace impecable siguiendo Clean Architecture:
  entidad + caso de uso en `domain`, repositorio en `data`, Riverpod en
  `presentation`. Se convierte en la PLANTILLA de cómo se hace una feature aquí.
- Las siguientes features copian ese patrón. Si la primera se hace a lo rápido,
  se arrastra el desorden a todas.
- Usar ya los componentes del sistema de diseño (M1), aunque sin pulir.

---

## Fase M3 — Robustez (lo que convierte un proyecto en producto)

Cuando el núcleo funcione. Capas que no se ven pero definen la calidad.

### M3.1 — Manejo de errores y estados consistente
- Estados de carga / error / vacío en TODA la app, no solo en auth.
- Qué pasa sin internet, si n8n no responde, si una query falla.
- Nunca dejar al usuario ante pantalla en blanco o crash.

### M3.2 — Observabilidad
- Captura de errores en producción (ej. Sentry, tiene plan gratuito).
- Logging mínimo para saber qué falla a usuarios reales.
- Sin esto, se lanza a ciegas.

### M3.3 — Testing
- Tests de la capa `domain` (Dart puro, trivial de testear) y de repositorios.
- No hace falta 100% de cobertura; sí cubrir la lógica crítica.
- La Clean Architecture está hecha precisamente para que esto sea fácil.

### M3.4 — Seguridad más allá del RLS
- Validación también en n8n (no confiar solo en el cliente).
- Rate limiting en los webhooks.
- Verificar aislamiento de la `service_role` (solo en n8n, nunca en Flutter).

---

## Fase M4 — Lanzamiento (cuando el producto ya es sólido)

No es código. Se aborda al final.

### M4.1 — Legal
- Política de privacidad y términos de uso.
- RGPD: si se manejan datos de salud/nutrición de usuarios europeos, aplica y es
  serio. Considerar consentimiento, derecho de borrado, minimización de datos.

### M4.2 — Despliegue de n8n en producción
- Sale de localhost: VPS con HTTPS, dominio propio.
- Backups del volumen de n8n (workflows y credenciales).
- Webhook accesible desde el móvil real (lo que el planning ya anticipaba).

### M4.3 — Publicación en stores
- Cuentas de desarrollador (Google Play / App Store).
- Fichas, capturas, iconos, descripción.

### M4.4 — Analítica
- Mínimo de métricas de uso para saber si la gente usa lo que se construye.

---

## UI: cuándo y cómo (guía de decisión)

Hay TRES cosas distintas que la gente mete en el saco de "la UI". Cada una tiene
su momento:

1. **Flujo y estructura de pantallas** (qué pantallas, navegación, qué campos).
   → DESDE EL PRINCIPIO. Ya se hace vía la carpeta `presentation` de cada feature.

2. **Sistema de diseño** (paleta, tipografía, espaciados, COMPONENTES reutilizables).
   → PRONTO, aunque básico (Fase M1). Es la diferencia entre cambiar el color en
   un sitio vs. tenerlo repetido a mano en 40 pantallas. Centralizado desde el día 1.
   Se puede diseñar en paralelo porque no depende de la lógica.

3. **Estilo final** (colores definitivos, animaciones, microinteracciones, pulido).
   → AL FINAL, cuando la funcionalidad está cerrada. Pulir píxeles sobre lógica que
   aún va a cambiar es trabajo que se tira.

**Regla práctica:** estructura primero, sistema de diseño pronto, pulido al final.

**Aplicado a "voy diseñando la UI estos días":** canaliza ese diseño hacia el
sistema de diseño y los componentes (M1), no hacia pantallas pulidas sueltas.
Construye las pantallas con funcionalidad usando esos componentes (aunque estén
sin estilar). Cuando llegue el pulido, tocas el theme y los componentes y todas
las pantallas se actualizan solas. Así ningún trabajo de diseño se desperdicia.

---

## Orden recomendado de ataque (inmediato)
1. Git + GitHub (M0.1) — hoy.
2. Completar auth (M0.2).
3. En paralelo: empezar sistema de diseño / componentes (M1).
4. Fase 1 comidas como plantilla de referencia (M2), usando los componentes.
5. A partir de ahí, intercalar robustez (M3) con las features 2 y 3.
6. Lanzamiento (M4) solo cuando el producto sea sólido.

No abordar M3/M4 ahora sería sobre-ingeniería sobre una base que aún no existe.
Pero tenerlas en el mapa evita decisiones que haya que deshacer.
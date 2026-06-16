# Clean Architecture en Dart / Flutter

Este documento sirve como guía de referencia para estructurar proyectos escalables y mantenibles, basándose en la Inversión de Dependencias y la separación por capas.

> Gestión de estado del proyecto: **Riverpod** (fijado en `specs/conventions.md`).
> Donde este documento menciona gestores de estado, se refiere a Riverpod.

## Estructura de carpetas (`lib/`)

```text
lib/
├── core/                  # Recursos compartidos y utilidades (themes, network, helpers)
│   ├── network/
│   ├── errors/
│   └── usecases/
├── features/              # Funcionalidades de la aplicación (Ej: auth, perfil, etc.)
│   ├── feature_name/
│   │   ├── data/          # Implementación de repositorios, DTOs y llamadas a APIs/BD
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/        # Reglas de negocio puras (Entidades, Casos de uso e Interfaces de repositorios)
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/  # UI (Widgets, Páginas) y Gestores de estado (Riverpod)
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── state/      # providers / notifiers de Riverpod
```

## Reglas de las Capas

1. **Dominio (Domain):** Es el núcleo de la aplicación. Contiene únicamente código Dart puro. **No debe importar nada de Flutter ni de Data.** Sus clases son:
   - *Entities:* Modelos de negocio centrales.
   - *Use Cases:* Casos de uso específicos (acciones que el usuario puede realizar).
   - *Repositories (Interface):* Contratos abstractos que definen qué datos se necesitan, pero no cómo se obtienen.

2. **Datos (Data):** Depende del Dominio. Es la responsable de comunicarse con fuentes externas (APIs, Base de datos local).
   - *Models/DTOs:* Clases que extienden a las Entities y añaden métodos como `fromJson` y `toJson`.
   - *DataSources:* Clases concretas que realizan las peticiones HTTP o consultas a la base de datos.
   - *Repositories (Implementation):* La implementación real del contrato de repositorios definido en el Dominio.

3. **Presentación (Presentation):** Depende del Dominio (para activar los casos de uso) y de Data (a veces, para inyectar dependencias).
   - *UI:* Pantallas y widgets que reaccionan a los cambios de estado.
   - *State Management:* **Riverpod** para gestionar la lógica visual y el estado (providers, notifiers).

## Dependencias
Las dependencias solo pueden apuntar **hacia adentro**. La capa de Dominio nunca debe conocer a la capa de Datos.

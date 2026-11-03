# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) al trabajar con el código de este repositorio.

## Comandos

```bash
# Ejecutar en dispositivo/emulador conectado
flutter run

# Compilar APK de release para Android (requiere android/key.properties)
flutter build apk --release

# Compilar App Bundle para Play Store
flutter build appbundle --release

# Ejecutar todas las pruebas
flutter test

# Regenerar adaptadores de Hive tras modificar modelos Hive
dart run build_runner build --delete-conflicting-outputs

# Regenerar archivos de localización (l10n)
flutter gen-l10n

# Analizar el código
flutter analyze
```

## Arquitectura

**Batidos Saludables** es una app Flutter de recetas de batidos y bebidas saludables orientada a Android (paquete `com.slisapps.batidossalud`, versión 1.3.0+16).

### Flujo de datos

Los datos de recetas se cargan al inicio desde `assets/json/Batidos_es.json` o `assets/json/Batidos_en.json` según el idioma activo, mediante `SmoothieProvider` (`lib/providers/provider.dart`). El provider parsea los objetos `Category` y `Recipe` y los expone en toda la app con el paquete `provider`. No se realizan peticiones de red para el contenido de recetas.

> Nota: `assets/json/Batidos.json` es un archivo legado que ya no se usa.

### Estructura de archivos

```
lib/
  main.dart                         # Entry point: init Firebase, Hive, alarmas, AdMob, providers, Bienvenida
  favoritos.dart                    # Modelo Hive @HiveType(typeId:0) — guarda id de receta como double
  favoritos.g.dart                  # Generado por Hive (no editar)
  alarms_functions.dart             # scheduleDailyAlarms, loadAndScheduleAlarms, phraseRandom
  main/
    main_screen.dart                # IndexedStack con 4 pestañas + BottomNav + BannerAd + FAB
  pantallas/
    home.dart                       # Carrusel + "Receta del día" (semilla = día del año) + listas horizontales
    categorias.dart                 # Grid de las 18 categorías
    pantalla_favoritos.dart         # Favoritos desde Hive box "Favoritos"
    searchScreen.dart               # Búsqueda global (sin acentos con paquete diacritic)
    listaRecetas.dart               # Recetas filtradas por categoría
    descripRecetas.dart             # Detalle: ingredientes, preparación, compartir, favoritar
  providers/
    provider.dart                   # SmoothieProvider: carga JSON según locale, expone categories y recetas
    locale_provider.dart            # LocaleProvider: detecta/guarda idioma (es/en) en Hive box "prefs"
  services/
    ad_helper.dart                  # IDs AdMob (test en debug, producción en release con kReleaseMode)
    analytics_service.dart          # Singleton Firebase Analytics: logRecipeViewed/Favorited/Shared/WaterReminderSet
    recipe_notification_service.dart # Notificación local "Tu batido del día" a las 8:00 AM
  models/
    categories_model.dart           # Clase Category: int id, String name_category, String image_category
    receta_model.dart               # Clase Recipe: double id, String name, listas de ingredientes y preparación
  functions/
    functions.dart                  # depuratedListReceta(categoryId), depuratedListFavoritos(idList)
    category_name.dart              # categoryLocalizedName(context, id) → switch 18 categorías → l10n
  l10n/
    app_en.arb                      # Strings inglés (plantilla fuente)
    app_es.arb                      # Strings español
    l10n_extension.dart             # Extension BuildContext.l10n para acceso rápido
    app_localizations*.dart         # Generados por flutter gen-l10n (no editar)
  ReminderWater/
    ReminderWater.dart              # Calculadora de consumo de agua + programador de alarmas diarias
```

### Estructura de navegación

```
main.dart → Bienvenida (splash + anuncio intersticial)
  └── MainScreen (IndexedStack, 4 pestañas + FAB búsqueda)
        ├── Home            – carrusel + "Receta del día" + listas por categoría
        ├── Categorias      – cuadrícula de 18 categorías
        ├── PantallaFavoritos – favoritos guardados en Hive
        └── ReminderWater   – calculadora agua + alarmas diarias
              (SearchScreen se abre desde el FAB)
```

### Gestión de estado

Dos `ChangeNotifier` registrados en `MultiProvider` en la raíz de la app:

| Provider | Archivo | Responsabilidad |
|----------|---------|----------------|
| `LocaleProvider` | `lib/providers/locale_provider.dart` | Idioma activo (`es`/`en`), persiste en Hive `prefs` |
| `SmoothieProvider` | `lib/providers/provider.dart` | Carga JSON según locale, expone `List<Category>` y `List<Recipe>` |

`SmoothieProvider` depende de `LocaleProvider` para saber qué JSON cargar. Al cambiar idioma se recarga el JSON completo.

### Persistencia local (Hive)

Cuatro cajas Hive se abren al inicio en `main.dart`:

| Caja | Tipo | Contenido |
|------|------|-----------|
| `Favoritos` | `Favoritos` (HiveObject) | IDs de recetas favoritas (double) |
| `listAlarms` | `String` | Horas formateadas para mostrar en UI |
| `alarms` | `String` | Duraciones en minutos para reprogramar al reiniciar |
| `prefs` | `String` | Idioma elegido: clave `app_locale` → `"es"` o `"en"` |

`Favoritos` tiene `@HiveType(typeId: 0)` en `lib/favoritos.dart`. Regenerar con `build_runner` si cambia el modelo.

### Alarmas / Recordatorio de agua

`lib/alarms_functions.dart` gestiona alarmas diarias con el paquete `alarm`:
- `scheduleDailyAlarms(List<Duration>)` – programa alarmas diarias
- `loadAndScheduleAlarms()` – carga de Hive y reprograma al reiniciar
- `phraseRandom()` – frase aleatoria de hidratación (respeta idioma activo)

El `BroadcastReceiver` de Android (`AlarmRebootReceiver.kt`) arranca un `FlutterEngine` headless al reiniciar el dispositivo y llama `reprogramAlarmsHandler()` vía `MethodChannel("com.slisapps.batidossalud/alarm")`.

### Notificación diaria de receta

`lib/services/recipe_notification_service.dart` programa una notificación local a las **8:00 AM** con el título "Tu batido del día". Métodos estáticos: `initialize()`, `isEnabled()`, `enable()`, `disable()`, `enableIfFirstTime()`. Se activa automáticamente en el primer arranque.

### Firebase

| Servicio | Propósito |
|----------|----------|
| `firebase_core` | Inicialización |
| `firebase_analytics` | Tracking: `recipe_viewed`, `recipe_favorited`, `recipe_shared`, `water_reminder_set` |
| `firebase_messaging` | Suscripción al topic `receta_del_dia` para notificaciones push remotas |

### Integración de AdMob

`lib/services/ad_helper.dart` devuelve IDs de prueba en debug e IDs reales (`ca-app-pub-6698527085132528/...`) en release con `kReleaseMode`. App ID: `ca-app-pub-6698527085132528~7867523325`.
- **Banner**: visible en el área inferior de `MainScreen` (sobre el `BottomNavigationBar`)
- **Intersticial bienvenida**: se muestra en la pantalla `Bienvenida` antes de navegar a `MainScreen`
- **Intersticial compartir**: se puede mostrar al compartir recetas desde `descripRecetas`

### Localización (i18n)

La app soporta **español** e **inglés**. Configurado con `flutter_localizations` + `intl`:
- Archivos fuente: `lib/l10n/app_en.arb` (plantilla) y `lib/l10n/app_es.arb`
- Acceso rápido: `context.l10n.nombreClave` mediante la extension en `lib/l10n/l10n_extension.dart`
- Los nombres de las 18 categorías se localizan en `lib/functions/category_name.dart`
- Los JSONs de datos también están duplicados por idioma (`Batidos_es.json` / `Batidos_en.json`)

### Modelos de datos

**`Category`** (`lib/models/categories_model.dart`):
- `int id`, `String name_category`, `String image_category`

**`Recipe`** (`lib/models/receta_model.dart`):
- `double id` (entero + decimales indica categoría, e.g. `3.5` → categoría 3)
- `String name`, `String image_smoothie`
- `List<String> ingredient_amount`, `ingredient_description`, `ingredient_icon`, `preparation`

### Utilidades de filtrado de recetas

`lib/functions/functions.dart`:
- `depuratedListReceta(recipes, categoryId)` – filtra por categoría usando `.floor()` porque `Recipe.id` es `double`
- `depuratedListFavoritos(recipes, idList)` – filtra para mostrar solo las recetas favoritas

### Firma para release

La compilación release requiere el archivo `android/key.properties` (no incluido en el repositorio). Debe definir `storeFile`, `storePassword`, `keyAlias` y `keyPassword`.

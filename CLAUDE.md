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

# Ejecutar un archivo de prueba específico
flutter test test/widget_test.dart

# Regenerar adaptadores de Hive tras modificar modelos Hive
dart run build_runner build --delete-conflicting-outputs

# Analizar el código
flutter analyze
```

## Arquitectura

**Batidos Saludables** es una app Flutter de recetas de batidos y bebidas saludables orientada a Android (paquete `com.slisapps.batidossalud`, version code 11 / nombre 1.1.6).

### Flujo de datos

Todos los datos de recetas se encuentran en `assets/json/Batidos.json`, que se carga una sola vez al inicio mediante `SmoothieProvider` (`lib/providers/provider.dart`). El provider parsea los objetos `Category` y `Recipe` y los pone disponibles en toda la app mediante el paquete `provider`. No se realizan peticiones de red para el contenido de recetas.

### Estructura de navegación

```
main.dart (pantalla Bienvenida + anuncio intersticial)
  └── MainScreen (navegación inferior, 4 pestañas + FAB búsqueda)
        ├── Home          – carrusel + listas horizontales por categoría
        ├── Categorias    – cuadrícula de todas las categorías
        ├── PantallaFavoritos – favoritos guardados en Hive
        └── ReminderWater – calculadora de consumo de agua + programador de alarmas
              (SearchScreen se abre desde el FAB)
```

`MainScreen` usa `IndexedStack` para mantener el estado de cada pestaña al cambiar entre ellas.

### Gestión de estado

`SmoothieProvider` (`lib/providers/provider.dart`) es el único `ChangeNotifier`, registrado en la raíz de la app. Almacena `List<Category> categories` y `List<Recipe> recetas` cargados desde el JSON. Las pantallas lo consumen con `Consumer<SmoothieProvider>` o `Provider.of`.

### Persistencia local (Hive)

Tres cajas Hive se abren al inicio en `main.dart`:

| Caja | Contenido |
|------|-----------|
| `Favoritos` | Objetos `Favoritos` (guarda el `id` de la receta como `double`) |
| `listAlarms` | Cadenas de hora formateadas que se muestran en la UI |
| `alarms` | Duraciones de alarma en minutos sin formato para reprogramar al reiniciar |

`Favoritos` es un modelo Hive con `@HiveType` en `lib/favoritos.dart`. Su adaptador generado está en `lib/favoritos.g.dart`; hay que regenerarlo con `build_runner` si el modelo cambia.

### Alarmas / Recordatorio de agua

`lib/alarms_functions.dart` gestiona la programación mediante el paquete `alarm`. Las alarmas se programan diariamente y se persisten en la caja Hive `alarms` para poder reprogramarlas al reiniciar el dispositivo. El `BroadcastReceiver` de Android llama de vuelta a través del `MethodChannel` `"com.example.batidos_salud/alarm"` → `reprogramAlarmsHandler()`.

### Integración de AdMob

`lib/services/ad_helper.dart` devuelve IDs de prueba en modo debug e IDs reales (`ca-app-pub-6698527085132528/...`) en modo release mediante `kReleaseMode`. Los anuncios de banner se muestran dentro del `bottomNavigationBar` de `MainScreen`. Un anuncio intersticial se reproduce en la pantalla de `Bienvenida` antes de navegar a `MainScreen`.

### Utilidades de filtrado de recetas

`lib/functions/functions.dart` provee dos funciones puras:
- `depuratedListReceta(recipes, categoryId)` – filtra recetas por categoría (el `id` de la receta es `double`; se usa `.floor()` para compararlo con el `int` del id de categoría).
- `depuratedListFavoritos(recipes, idList)` – filtra recetas para obtener solo las guardadas como favoritos.

### Firma para release

La compilación release requiere el archivo `android/key.properties` (no incluido en el repositorio). Debe definir `storeFile`, `storePassword`, `keyAlias` y `keyPassword`.

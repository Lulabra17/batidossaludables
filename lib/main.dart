import 'package:alarm/alarm.dart';
import 'package:batidos_salud/alarms_functions.dart';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/main/main_screen.dart';
import 'package:batidos_salud/providers/provider.dart';
import 'package:batidos_salud/services/ad_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'favoritos.dart';

// configurando canales para reprogramar alarmas en un reinicio
@pragma('vm:entry-point')
Future<void> reprogramAlarmsHandler() async {
  try {
    await loadAndScheduleAlarms();
  } catch (e) {
    debugPrint('⚠️ reprogramAlarmsHandler: canal no disponible en background ($e)');
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize(); // INICIALIZAMOS ADMOB

  await Alarm.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configuramos el MethodChannel para recibir la llamada del BroadcastReceiver
  const MethodChannel channel = MethodChannel("com.example.batidos_salud/alarm");
  channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == "reprogramAlarms") {
      await reprogramAlarmsHandler();
    }
  });

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(FavoritosAdapter());

  await Hive.openBox('Favoritos');
  await Hive.openBox('listAlarms');
  await Hive.openBox('alarms');
  await Hive.openBox('prefs');

  // Pedir permisos antes de programar alarmas/notificaciones
  await requestPermissions();

  try {
    await loadAndScheduleAlarms(); // Cargar y reprogramar alarmas al iniciar
  } catch (e) {
    debugPrint('⚠️ loadAndScheduleAlarms en startup: $e');
  }

  // Inicializar Firebase y suscribir al topic de receta diaria
  await Firebase.initializeApp();
  await _setupFCM();

  runApp(MyApp());
}

Future<void> _setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Solicitar permiso de notificaciones (necesario en iOS y Android 13+)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Suscribir al topic — todos los dispositivos reciben la notificación diaria
  await messaging.subscribeToTopic('receta_del_dia');

  // Manejar notificaciones cuando la app está en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 FCM foreground: ${message.notification?.title}');
  });
}

Future<void> requestPermissions() async {
  // Android 13+: permiso de notificaciones en tiempo de ejecución
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  // SCHEDULE_EXACT_ALARM se solicita solo cuando el usuario activa recordatorios de agua
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
        create: (context) => SmoothieProvider(),
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Título localizado — usa onGenerateTitle porque title se evalúa antes que los delegates
        onGenerateTitle: (context) => context.l10n.appTitle,
        // Configuración de internacionalización
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // inglés — idioma por defecto
          Locale('es'), // español
        ],
        // Si el celular está en español se usa español; cualquier otro idioma usa inglés
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale?.languageCode == 'es') return const Locale('es');
          return const Locale('en');
        },
        home: const Bienvenida(),
      ),
    );
  }
}
class Bienvenida extends StatefulWidget {
  const Bienvenida({super.key});

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  // El intersticial solo se muestra a partir del 2° inicio para no bloquear la primera experiencia
  static const _launchCountKey = 'launch_count';
  final _prefsBox = Hive.box('prefs');

  @override
  void initState() {
    super.initState();
    _incrementLaunchCount();
    _loadInterstitialAd();
  }

  void _incrementLaunchCount() {
    final count = (_prefsBox.get(_launchCountKey) as int? ?? 0) + 1;
    _prefsBox.put(_launchCountKey, count);
  }

  bool get _shouldShowAd {
    final count = _prefsBox.get(_launchCountKey) as int? ?? 0;
    return count >= 2;
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitIdwelcome,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              goToMainScreen();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              goToMainScreen();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Error al cargar interstitial: $error');
          _isAdReady = false;
          goToMainScreen();
        },
      ),
    );
  }

  void showInterstitialAdIfAllowed() {
    if (_shouldShowAd && _isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      goToMainScreen();
    }
  }

  void goToMainScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  l10n.welcomeMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.brown[900],
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.teal[300],
                    elevation: 0,
                  ),
                  onPressed: showInterstitialAdIfAllowed,
                  child: Text(l10n.welcomeButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
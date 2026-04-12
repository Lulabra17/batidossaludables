import 'dart:ui';
import 'package:alarm/alarm.dart';
import 'package:batidos_salud/alarms_functions.dart';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/main/main_screen.dart';
import 'package:batidos_salud/providers/provider.dart';
import 'package:batidos_salud/services/ad_helper.dart';
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
  await loadAndScheduleAlarms();
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

  await loadAndScheduleAlarms(); // Cargar y reprogramar alarmas al iniciar
  //setupRepeatingAlarms();

 // Pedir permisos
  await requestPermissions();

  runApp(MyApp());
}

Future<void> requestPermissions() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    if (await Permission.scheduleExactAlarm.shouldShowRequestRationale) {
      await Permission.scheduleExactAlarm.request();
    } else {
      print("⚠️ Habilita manualmente SCHEDULE_EXACT_ALARM en Configuración.");
      openAppSettings();
    }
  }
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
  DateTime? _lastInterstitialShown;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitIdwelcome,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('✅ Interstitial Ad cargado');
          _interstitialAd = ad;
          _isAdReady = true;

          // Manejar eventos del anuncio
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('🔚 Interstitial cerrado');
              _lastInterstitialShown = DateTime.now();
              ad.dispose();
              goToMainScreen();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('❌ Error al mostrar interstitial: $error');
              ad.dispose();
              goToMainScreen();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Error al cargar interstitial: $error');
          _isAdReady = false;
          goToMainScreen();
        },
      ),
    );
  }

  void showInterstitialAdIfAllowed() {
    final now = DateTime.now();
    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!) < const Duration(minutes: 2)) {
      print('⏱️ Interstitial limitado (espera 2 minutos)');
      goToMainScreen();
      return;
    }

    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('⚠️ Interstitial no cargado o no listo');
      goToMainScreen();
    }
  }

  void goToMainScreen() {
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
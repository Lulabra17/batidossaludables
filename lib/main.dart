import 'package:alarm/alarm.dart';
import 'package:batidos_salud/alarms_functions.dart';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/main/main_screen.dart';
import 'package:batidos_salud/providers/locale_provider.dart';
import 'package:batidos_salud/providers/provider.dart';
import 'package:batidos_salud/services/ad_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:batidos_salud/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' show pi;
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

  // Inicializar Firebase antes de runApp
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await _setupFCM();

  // Pedir permisos antes de programar alarmas/notificaciones
  await requestPermissions();

  try {
    await loadAndScheduleAlarms(); // Cargar y reprogramar alarmas al iniciar
  } catch (e) {
    debugPrint('⚠️ loadAndScheduleAlarms en startup: $e');
  }

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(Hive.box('prefs')),
        ),
        ChangeNotifierProxyProvider<LocaleProvider, SmoothieProvider>(
          create: (_) => SmoothieProvider(),
          update: (_, localeProvider, smoothieProvider) {
            smoothieProvider!.loadData(
              locale: localeProvider.locale.languageCode,
            );
            return smoothieProvider;
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [AnalyticsService.instance.observer],
          locale: localeProvider.locale,
          onGenerateTitle: (context) => context.l10n.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          theme: ThemeData(
            useMaterial3: false,
            primaryColor: const Color(0xFF00695C),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00695C),
              secondary: Color(0xFF2BBFAA),
              surface: Color(0xFFFAFAF8),
            ),
            scaffoldBackgroundColor: const Color(0xFFFAFAF8),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
              shadowColor: Colors.grey,
              iconTheme: IconThemeData(color: Colors.black54),
            ),
            bottomAppBarTheme: const BottomAppBarThemeData(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.grey,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          home: const Bienvenida(),
        ),
      ),
    );
  }
}
class Bienvenida extends StatefulWidget {
  const Bienvenida({super.key});

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> with TickerProviderStateMixin {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  static const _launchCountKey = 'launch_count';
  final _prefsBox = Hive.box('prefs');

  // Animación entrada logo: spin + escala + fade
  late final AnimationController _entranceCtrl;
  late final Animation<double> _spinAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  // Animación loop logo: floating
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Animación entrada KIMO: fade in retrasado
  late final AnimationController _kimoFadeCtrl;
  late final Animation<double> _kimoFadeAnim;

  @override
  void initState() {
    super.initState();
    _incrementLaunchCount();
    _loadInterstitialAd();
    _setupAnimations();
  }

  void _setupAnimations() {
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _spinAnim = Tween<double>(begin: -2 * pi, end: 0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _floatAnim = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _kimoFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _kimoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _kimoFadeCtrl, curve: Curves.easeIn),
    );

    // Logo entra → arranca floating → 1s después aparece KIMO
    _entranceCtrl.forward().whenComplete(() {
      _floatCtrl.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _kimoFadeCtrl.forward();
      });
    });
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
    _entranceCtrl.dispose();
    _floatCtrl.dispose();
    _kimoFadeCtrl.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF004D40),
              Color(0xFF00695C),
              Color(0xFF00897B),
              Color(0xFF26A69A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // ── Logo + KIMO (Stack: logo detrás, KIMO encima) ─────
              SizedBox(
                height: size.height * 0.62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logo — detrás, más ancho que KIMO
                    AnimatedBuilder(
                      animation: Listenable.merge([_entranceCtrl, _floatCtrl]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: Transform.rotate(
                            angle: _spinAnim.value,
                            child: Transform.scale(
                              scale: _scaleAnim.value,
                              child: Opacity(
                                opacity: _fadeAnim.value,
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/logo_batidos.png',
                        width: size.width * 0.82,
                      ),
                    ),

                    // KIMO — encima, centrado con leve desplazamiento hacia abajo
                    Align(
                      alignment: const Alignment(0, 0.25),
                      child: FadeTransition(
                        opacity: _kimoFadeAnim,
                        child: Image.asset(
                          'assets/images/kimo_bienvenida.png',
                          width: size.width * 0.70,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Slogan ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  l10n.appSlogan,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Botón ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00695C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: showInterstitialAdIfAllowed,
                    child: Text(l10n.welcomeButton),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


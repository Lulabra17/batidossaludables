import 'package:batidos_salud/pantallas/categorias.dart';
import 'package:batidos_salud/pantallas/home.dart';
import 'package:batidos_salud/pantallas/pantalla_favoritos.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ReminderWater/ReminderWater.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAdMobBanner();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _loadAdMobBanner() {
    _bannerAd = BannerAd(
      //adUnitId: 'ca-app-pub-6698527085132528/5073839022', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // PRUEBA
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
          print('✅ Banner cargado');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('❌ Error al cargar banner: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido Principal
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Home(),
                Categorias(),
                PantallaFavoritos(),
              ],
            ),
          ),

          // FAB
          const Positioned(
            width: 80,
            height: 80,
            bottom: 80,
            right: 16,
            child: _RecordatorioButton(),
          ),

          // Banner AdMob
          if (_isBannerLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.teal[300],
        currentIndex: _selectedIndex,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
        selectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/iconohome.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class _RecordatorioButton extends StatelessWidget {
  const _RecordatorioButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey[600],
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ReminderWater()),
        );
      },
      child: Image.asset('assets/images/icono_clock.png'),
    );
  }
}
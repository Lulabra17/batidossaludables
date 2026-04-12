import 'package:batidos_salud/pantallas/categorias.dart';
import 'package:batidos_salud/pantallas/home.dart';
import 'package:batidos_salud/pantallas/pantalla_favoritos.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
import 'package:batidos_salud/services/ad_helper.dart';
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

  double get _bannerHeight =>
      _isBannerLoaded && _bannerAd != null
          ? _bannerAd!.size.height.toDouble()
          : 0;

  @override
  void initState() {
    super.initState();
    _loadAdMobBanner();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  void _loadAdMobBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerLoaded = true);
          debugPrint('✅ Banner cargado');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('❌ Error al cargar banner: $error');
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFAFAF8),

      // ✅ Body limpio, solo el IndexedStack
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Home(),
          const Categorias(),
          PantallaFavoritos(),
          ReminderWater(),
        ],
      ),

      // ✅ FAB central con búsqueda
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[600],
        elevation: 6.0,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
        child: const Icon(Icons.search, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ Banner + BottomAppBar en Column
      bottomNavigationBar:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            BottomAppBar(
              shape: const CircularNotchedRectangle(),
              shadowColor: Colors.grey,
              notchMargin: 8.0,
              elevation: 4.0,
              color: Colors.white,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // ← Izquierda
                  IconButton(
                    icon: ImageIcon(
                      const AssetImage('assets/images/iconohome.png'),
                      color: _selectedIndex == 0
                          ? Colors.teal[600]
                          : Colors.black45,
                    ),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: _selectedIndex == 1
                          ? Colors.teal[600]
                          : Colors.black45,
                    ),
                    onPressed: () => _onItemTapped(1),
                  ),

                  const SizedBox(width: 48), // hueco para el FAB

                  // → Derecha
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: _selectedIndex == 2
                          ? Colors.teal[600]
                          : Colors.black45,
                    ),
                    onPressed: () => _onItemTapped(2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.water_drop,
                      color: _selectedIndex == 3
                          ? Colors.teal[600]
                          : Colors.black45,
                    ),
                    onPressed: () => _onItemTapped(3),
                  ),
                ],
              ),
            ),
            if (_isBannerLoaded && _bannerAd != null)
              SizedBox(
                height: _bannerHeight,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
    );
  }
}
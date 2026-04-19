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
  bool _searchPressed = false;

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
          if (mounted) setState(() => _isBannerLoaded = true);
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

      // ✅ Body con banner como overlay fijo en la parte inferior
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _isBannerLoaded ? _bannerHeight : 0),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const Home(),
                const Categorias(),
                PantallaFavoritos(),
                ReminderWater(),
              ],
            ),
          ),
          if (_isBannerLoaded && _bannerAd != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  height: _bannerHeight,
                  width: _bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),

      // ✅ BottomAppBar con FAB embebido en el centro — banner en body overlay queda libre
      bottomNavigationBar: BottomAppBar(
        shadowColor: Colors.grey,
        elevation: 4.0,
        color: Colors.white,
        height: 62,
        clipBehavior: Clip.none,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ← Izquierda
            IconButton(
              icon: ImageIcon(
                const AssetImage('assets/images/iconohome.png'),
                color: _selectedIndex == 0 ? Colors.teal[600] : Colors.black45,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: _selectedIndex == 1 ? Colors.teal[600] : Colors.black45,
              ),
              onPressed: () => _onItemTapped(1),
            ),

            // Botón de búsqueda con animación de escala al presionar
            GestureDetector(
              onTapDown: (_) => setState(() => _searchPressed = true),
              onTapUp: (_) => setState(() => _searchPressed = false),
              onTapCancel: () => setState(() => _searchPressed = false),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              ),
              child: SizedBox(
                width: 72,
                height: 62,
                child: OverflowBox(
                  maxWidth: 72,
                  maxHeight: 80,
                  child: AnimatedScale(
                  scale: _searchPressed ? 0.85 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal[600],
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            ),

            // → Derecha
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: _selectedIndex == 2 ? Colors.teal[600] : Colors.black45,
              ),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                Icons.water_drop,
                color: _selectedIndex == 3 ? Colors.teal[600] : Colors.black45,
              ),
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
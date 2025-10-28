import 'package:batidos_salud/models/receta_model.dart';
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../functions/functions.dart';
import '../models/categories_model.dart';
import '../providers/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ListaRecetas extends StatefulWidget {
  final Category category;
  const ListaRecetas({super.key, required this.category});

  @override
  State<ListaRecetas> createState() => _ListaRecetasState();
}

class _ListaRecetasState extends State<ListaRecetas> {
  BannerAd? _adMobBanner;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadAdMobBanner();
  }

  void _loadAdMobBanner() {
    _adMobBanner = BannerAd(
      //adUnitId: 'ca-app-pub-6698527085132528/5073839022', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // PRUEBA
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          print('Error al cargar AdMob banner: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _adMobBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int idcategory = widget.category.id;
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    final List<Recipe> listaReceta = depuratedListReceta(smProvider.recetas, idcategory);

    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Batidos ${widget.category.name_category}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.teal[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: _isBannerAdReady ? 60 : 0),
              child: Consumer<SmoothieProvider>(
                builder: (context, provider, child) {
                  return SingleChildScrollView(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: listaReceta.length,
                      itemBuilder: (context, index) {
                        return cardReceta(context, listaReceta[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isBannerAdReady && _adMobBanner != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  height: _adMobBanner!.size.height.toDouble(),
                  width: _adMobBanner!.size.width.toDouble(),
                  child: AdWidget(ad: _adMobBanner!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget cardReceta(BuildContext context, dynamic recipe) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => descripReceta(recipe: recipe)),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 125,
        child: Card(
          elevation: 8.0,
          child: Row(
            children: [
              Container(
                width: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('${recipe.image_smoothie}'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  '${recipe.name}',
                  style: TextStyle(
                    color: Colors.green[900],
                    fontFamily: 'Quicksand',
                    fontSize: MediaQuery.of(context).size.width * 0.040,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
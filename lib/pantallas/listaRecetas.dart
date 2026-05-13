import 'package:batidos_salud/models/receta_model.dart';
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../functions/category_name.dart';
import '../functions/functions.dart';
import '../models/categories_model.dart';
import '../providers/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_helper.dart';

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
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error al cargar AdMob banner: $error');
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
      backgroundColor: Color(0xFFE8E8DE),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[600]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryLocalizedName(context, widget.category.id),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: MediaQuery.of(context).size.width*0.04),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.teal[600]),
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
              padding: EdgeInsets.only(bottom: _isBannerAdReady ? _adMobBanner!.size.height.toDouble() : 0),
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
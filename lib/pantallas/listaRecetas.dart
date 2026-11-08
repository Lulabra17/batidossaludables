import 'package:batidos_salud/models/receta_model.dart';
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryLocalizedName(context, widget.category.id),
          style: GoogleFonts.nunito(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: SizedBox(
        height: 90,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: Image.asset(
                  '${recipe.image_smoothie}',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${recipe.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: MediaQuery.of(context).size.width * 0.040,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25), size: 20),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
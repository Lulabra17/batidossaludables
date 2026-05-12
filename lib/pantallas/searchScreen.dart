import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diacritic/diacritic.dart';
import '../models/receta_model.dart';
import '../models/categories_model.dart';
import '../providers/provider.dart';
import '../services/ad_helper.dart';
import 'categorias.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";
  List<Recipe> _filteredRecipes = [];
  List<Category> _filteredCategories = [];

  late List<Recipe> _allRecipes;
  late List<Category> _allCategories;

  late BannerAd _admobBanner;
  bool _isAdmobBannerReady = false;

  @override
  void initState() {
    super.initState();

    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    _allRecipes = smProvider.recetas;
    _allCategories = smProvider.categories;

    _admobBanner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdmobBannerReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Falló la carga del banner: $error');
          ad.dispose();
        },
      ),
    );

    // Delay banner load until after route transition + keyboard animation (~700ms total)
    // to avoid AdMob PlatformView initialization blocking the main thread
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _admobBanner.load();
    });
  }

  @override
  void dispose() {
    _admobBanner.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final normalized = removeDiacritics(value.toLowerCase());
    setState(() {
      _searchQuery = value;
      if (value.isEmpty) {
        _filteredRecipes = [];
        _filteredCategories = [];
      } else {
        _filteredCategories = _allCategories.where((category) {
          return removeDiacritics(category.name_category.toLowerCase())
              .contains(normalized);
        }).toList();

        _filteredRecipes = _allRecipes.where((recipe) {
          final name = removeDiacritics(recipe.name.toLowerCase());
          final ingredients = recipe.ingredient_description
              .map((ingredient) => removeDiacritics(ingredient.toLowerCase()))
              .join(" ");
          return name.contains(normalized) || ingredients.contains(normalized);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFAFAF8),
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.black38),
          ),
          style: const TextStyle(color: Colors.black),
          cursorColor: Colors.teal,
        ),
        backgroundColor: Color(0xFFFAFAF8),
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: _isAdmobBannerReady ? _admobBanner.size.height.toDouble() : 0),
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.searchPrompt,
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : _filteredCategories.isNotEmpty
                      ? ListView.builder(
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            return cardCategoria(context, _filteredCategories[index]);
                          },
                        )
                      : _filteredRecipes.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.noResults,
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredRecipes.length,
                              itemBuilder: (context, index) {
                                return cardReceta(context, _filteredRecipes[index]);
                              },
                            ),
            ),
          ),

          if (_isAdmobBannerReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  height: _admobBanner.size.height.toDouble(),
                  child: AdWidget(ad: _admobBanner),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
  String searchQuery = "";

  late BannerAd _admobBanner;
  bool _isAdmobBannerReady = false;

  @override
  void initState() {
    super.initState();

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

    _admobBanner.load();
  }

  @override
  void dispose() {
    _admobBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    final allRecipes = smProvider.recetas;
    final allCategories = smProvider.categories;

    final normalizedSearchQuery = removeDiacritics(searchQuery.toLowerCase());

    final List<Recipe> filteredRecipes = allRecipes.where((recipe) {
      final name = removeDiacritics(recipe.name.toLowerCase());
      final ingredients = recipe.ingredient_description
          .map((ingredient) => removeDiacritics(ingredient.toLowerCase()))
          .join(" ");
      return name.contains(normalizedSearchQuery) || ingredients.contains(normalizedSearchQuery);
    }).toList();

    final List<Category> filteredCategories = allCategories.where((category) {
      final categoryName = removeDiacritics(category.name_category.toLowerCase());
      return categoryName.contains(normalizedSearchQuery);
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFAFAF8),
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            border: InputBorder.none,
            hintStyle: const TextStyle(color: Colors.black38),
          ),
          style: const TextStyle(color: Colors.black),
          cursorColor: Colors.teal,
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: _isAdmobBannerReady ? _admobBanner.size.height.toDouble() : 0),
              child: searchQuery.isEmpty
                  ? Center(
                child: Text(
                  context.l10n.searchPrompt,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : filteredCategories.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  return cardCategoria(context, filteredCategories[index]);
                },
              )
                  : filteredRecipes.isEmpty
                  ? Center(
                child: Text(
                  context.l10n.noResults,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) {
                  return cardReceta(context, filteredRecipes[index]);
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
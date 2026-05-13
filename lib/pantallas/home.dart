import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../functions/category_name.dart';
import '../functions/functions.dart';
import '../models/receta_model.dart';
import '../providers/locale_provider.dart';
import '../providers/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Selecciona la receta del día usando el día del año como semilla,
  /// así todos los usuarios ven la misma receta cada día.
  Recipe _recipeOfDay(List<Recipe> recipes) {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return recipes[dayOfYear % recipes.length];
  }

  Widget _buildRecipeOfDayCard(BuildContext context, List<Recipe> recipes) {
    if (recipes.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final recipe = _recipeOfDay(recipes);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => descripReceta(recipe: recipe)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF008776), Color(0xFF2BBFAA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2BBFAA).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  recipe.image_smoothie,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recipeDayCardTitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryLocalizedName(context, recipe.id.toInt()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DE),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text(context.l10n.homeTitle,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.04),
            )),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black54),
            onPressed: () => _showLanguageDialog(context),
          ),
        ],
      ),
      body: Stack(children: [
        Consumer<SmoothieProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 222,
                        viewportFraction: 0.95,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.3,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: smProvider.categories.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ListaRecetas(category: i)));
                              },
                              child: Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      offset: Offset(4, 6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(i.image_category, fit: BoxFit.cover),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [Colors.transparent, Colors.black87],
                                            ),
                                          ),
                                          child: Text(
                                            categoryLocalizedName(context, i.id),
                                            style: GoogleFonts.nunito(
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  _buildRecipeOfDayCard(context, smProvider.recetas),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.categories.length,
                            itemBuilder: (context, index) {
                              return listxCategoria(
                                  context, provider.categories[index]);
                            },
                          ),
                          SizedBox(height: 125)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final current = localeProvider.locale.languageCode;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.language, color: Colors.teal),
            SizedBox(width: 8),
            Text('Idioma / Language'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageTile(
              context,
              flag: '🇪🇸',
              label: 'Español',
              code: 'es',
              selected: current == 'es',
              provider: localeProvider,
            ),
            _languageTile(
              context,
              flag: '🇺🇸',
              label: 'English',
              code: 'en',
              selected: current == 'en',
              provider: localeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(
    BuildContext context, {
    required String flag,
    required String label,
    required String code,
    required bool selected,
    required LocaleProvider provider,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
      onTap: () {
        provider.setLocale(code);
        Navigator.pop(context);
      },
    );
  }
}

Widget listxCategoria(BuildContext context, dynamic category) {
  final int idcategory = category.id;
  int ic = 0;
  final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
  final List<Recipe> listaReceta =
  depuratedListReceta(smProvider.recetas, idcategory);
  if (listaReceta.length <= 5) {
    ic = listaReceta.length;
  } else {
    ic = 5;
  }
  return SizedBox(
    height: 200,
    width: MediaQuery.of(context).size.width,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(categoryLocalizedName(context, category.id),
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.05),
                    )),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ListaRecetas(category: category)));
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.black,
                  iconSize: 18),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: ic,
              itemBuilder: (context, index) {
                return cardBatidos(context, listaReceta[index]);
              }),
        ),
      ],
    ),
  );
}

Widget cardBatidos(BuildContext context, dynamic recipe) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => descripReceta(recipe: recipe)));
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 0, bottom: 5, top: 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('${recipe.image_smoothie}'),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                recipe.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
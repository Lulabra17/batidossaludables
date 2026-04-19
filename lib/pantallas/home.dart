import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:batidos_salud/services/recipe_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../functions/functions.dart';
import '../models/receta_model.dart';
import '../providers/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _notifEnabled = RecipeNotificationService.isEnabled();

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
              // Imagen de la receta
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
              // Textos
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón de notificación
              GestureDetector(
                onTap: () async {
                  if (_notifEnabled) {
                    await RecipeNotificationService.disable();
                  } else {
                    await RecipeNotificationService.enable(
                      title: l10n.recipeDayNotifTitle,
                      body: l10n.recipeDayNotifBody,
                    );
                  }
                  setState(() => _notifEnabled = !_notifEnabled);
                },
                child: Tooltip(
                  message: _notifEnabled
                      ? l10n.recipeDayActive
                      : l10n.recipeDayActivate,
                  child: Icon(
                    _notifEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
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
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black54,
                                        offset: Offset(4, 6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                    image: DecorationImage(
                                        image: AssetImage(i.image_category),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey),
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
                child: Text(context.l10n.smoothiesCategoryTitle(category.name_category),
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
                  icon: Icon(Icons.more_vert),
                  color: Colors.black,
                  iconSize: 25),
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
          child: Center(child: Text(''))),
    ),
  );
}
import 'package:batidos_salud/pantallas/descripRecetas.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text('Bebidas Saludables \ndesde Casa',
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.04),
            )),
        backgroundColor: Colors.teal[300],
        shadowColor: Colors.grey,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          )
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
                        final index = i.id - 1;
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
                                        image: AssetImage(provider
                                            .categories[index].image_category),
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
                child: Text('Batidos ${category.name_category}',
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

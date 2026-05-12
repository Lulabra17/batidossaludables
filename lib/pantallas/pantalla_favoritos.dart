
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../functions/functions.dart';
import 'descripRecetas.dart';
import 'package:hive/hive.dart';

class PantallaFavoritos extends StatefulWidget {
  const PantallaFavoritos({super.key});

  @override
  State<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends State<PantallaFavoritos> {
  var box = Hive.box('Favoritos');

  @override
  Widget build(BuildContext context) {
    final List listId = box.values.toList().cast();
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    final List listafavoritos =
        depuratedListFavoritos(smProvider.recetas, listId);


    return Scaffold(
        backgroundColor: Color(0xFFE8E8DE),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          title: Text(context.l10n.favoritesTitle,
            style: GoogleFonts.nunito(textStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.04),
            ),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,),
        body: Builder(
          builder: (context) {
            if (listafavoritos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.teal[300]),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.noFavorites,
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: listafavoritos.length,
                      itemBuilder: (context, index) {
                        return cardReceta(context, index, listafavoritos[index], () {
                          setState(() {
                            final recipeId = '${listafavoritos[index].id}';
                            box.delete(recipeId);
                          });
                        });
                      },
                    ),
                    SizedBox(height: 125),
                  ],
                ),
              );
            }
          }
        ));
  }
}

Widget cardReceta(
BuildContext context, int index, dynamic recipe, void Function() delete) {
  int id = recipe.id.toInt();
  final nombreCategoria = Provider.of<SmoothieProvider>(context, listen: false).getCategoryNameById(id);
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => descripReceta(recipe: recipe)));
    },
    child: Padding(
      //para darle espaciado
      padding: const EdgeInsets.all(6.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 125,
        child: Card(
          elevation: 4.0,
          child: Row(
            children: <Widget>[
              Hero(
                tag: 'receta-${recipe.id}',
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('${recipe.image_smoothie}'),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${recipe.name}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.teal[800],
                            fontSize: MediaQuery.of(context).size.width * 0.040,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 4),
                    Text(context.l10n.smoothiesCategoryTitle(nombreCategoria),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: MediaQuery.of(context).size.width * 0.030,
                        ),
                      ))
                  ],
                ),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    delete.call();
                  }),
            ],
          ),
        ),
      ),
    ),
  );
}

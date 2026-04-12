
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../functions/functions.dart';
import 'descripRecetas.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

class PantallaFavoritos extends StatefulWidget {
  PantallaFavoritos({super.key});

  @override
  State<PantallaFavoritos> createState() => _PantallaFavoritosState();
}

class _PantallaFavoritosState extends State<PantallaFavoritos> {
  var box = Hive.box('Favoritos');

  Future<bool> initBox() async {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    await Hive.openBox('Favoritos');
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initBox();
  }

  @override
  Widget build(BuildContext context) {
    final List listId = box.values.toList().cast();
    print(box.toMap());
    print(listId);
    final smProvider = Provider.of<SmoothieProvider>(context, listen: false);
    print(smProvider.recetas);
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
              //box.clear();
              return Center(child: Text(context.l10n.noFavorites));
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
                            box.deleteAt(index);
                            if (listafavoritos.length == 1) {
                              box.clear();
                            };
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
          elevation: 8.0,
          color: Colors.black54,
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
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('${recipe.name}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.amberAccent,
                            fontFamily: 'Quicksand',
                            fontSize: MediaQuery.of(context).size.width * 0.040,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 8,
                    ),
                    Text(context.l10n.smoothiesCategoryTitle(nombreCategoria),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontSize: MediaQuery.of(context).size.width * 0.025,
                          fontWeight: FontWeight.bold))
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

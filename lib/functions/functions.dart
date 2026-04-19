
import 'package:batidos_salud/models/receta_model.dart';


//funcion para reducir la lista de todas las recetas a solo las de una categoria en especial,
//tiene como entradas la lista de recetas y un id de categoria
List<Recipe> depuratedListReceta(List<Recipe> recipescomplete, int categoryId) {
  final List<Recipe> newListReceta = [];
  for (var i = 0; i < recipescomplete.length; i++) {
    if (recipescomplete[i].id.floor() == categoryId) {
      newListReceta.add(recipescomplete[i]);
    }
  }
  recipescomplete = newListReceta;
  return recipescomplete;}


List depuratedListFavoritos(List<Recipe> recipesComplete, List list) {
  final List newListReceta = [];
  // Iterar sobre los valores de la lista de IDs
  if (list.isNotEmpty) {
    for (var fav in list.toSet()) {  // el .toSet() elimina duplicados
      // Buscar la receta que coincida con el id
      for (var recipe in recipesComplete) {
        if (recipe.id.toString() == fav) {
          newListReceta.add(recipe);
        }
    }
  }}
  return newListReceta; // Retornar la nueva lista filtrada
}
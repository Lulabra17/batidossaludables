import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:batidos_salud/models/categories_model.dart';
import 'package:batidos_salud/models/receta_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class SmoothieProvider extends ChangeNotifier {
  List<Category> categories = [];
  List<Recipe> recetas = [];

  SmoothieProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      final value = await rootBundle.loadString('assets/json/Batidos.json');
      Map data = jsonDecode(value);

      categories = List.from(
        data['categories'].map((category) => Category.fromJSON(category)),
      );

      for (int index = 0; index < categories.length; index++) {
        List<Recipe> recetasAdd = List.from(
          data['categories'][index]['recipes']
              .map((recipe) => Recipe.fromJSON(recipe)),
        );
        recetas.addAll(recetasAdd);
      }

      notifyListeners();
    } catch (e) {
      // Manejo de errores
      print("Error loading data: $e");
    }
  }

  // 👇 Esta es la función que estás pidiendo
  String getCategoryNameById(int id) {
    try {
      final category = categories.firstWhere(
            (cat) => cat.id == id,
        orElse: () => Category(id: -1, name_category: '', image_category: ''),
      );
      return category.id != -1 ? category.name_category : '';
    } catch (e) {
      return '';
    }
  }
}





import "package:equatable/equatable.dart";

class Recipe extends Equatable{
  double id;
  String image_smoothie;
  String name;
  List<String> ingredient_amount;
  List<String> ingredient_description;
  List<String> ingredient_icon;
  List<String> preparation;
  Recipe({
    required this.id,
    required this.image_smoothie,
    required this.name,
    required this.ingredient_amount,
    required this.ingredient_description,
    required this.ingredient_icon,
    required this.preparation
  });

  factory Recipe.fromJSON(Map<String, dynamic> json){
    return Recipe(
        id: json['id'],
        image_smoothie: json['image_smoothie'],
        name: json['name'],
        ingredient_amount: List<String>.from(json['ingredient_amount']),
        ingredient_description: List<String>.from(json['ingredient_description']),
        ingredient_icon: List<String>.from(json['ingredient_icon']),
        preparation: List<String>.from(json['preparation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_smoothie': image_smoothie,
      'name': name,
      'ingredient_amount':  ingredient_amount,
      'ingredient_description':  ingredient_description,
      'ingredient_icon':  ingredient_icon,
      'preparation': preparation
    };
  }

  @override
  String toString(){
    return 'Recipe{id: $id, image_smoothie: $image_smoothie, name: $name, ingredient_amount: $ingredient_amount, '
        'ingredient_description: $ingredient_description, ingredient_icon: $ingredient_icon, preparation: $preparation}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

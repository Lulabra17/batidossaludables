

class Category{
  int id;
  String name_category;
  String image_category;
  //List<Recipe> recipes;
  Category({
    required this.id,
    required this.name_category,
    required this.image_category,
   // required this.recipes,
  });

  factory Category.fromJSON(Map<String, dynamic> json){
    return Category(
        id: json['id'],
        name_category: json['name_category'],
        image_category: json['image_category'],
       // recipes: List<Recipe>.from(json['recipes'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_category': name_category,
      'image_category': image_category,
    };
  }

  @override
  String toString(){
    return 'Category{id: $id, name_category: $name_category, image_category: $image_category}';
  }

}
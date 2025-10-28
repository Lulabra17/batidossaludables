import 'package:hive/hive.dart';

part 'favoritos.g.dart';

@HiveType(typeId : 0)
class Favoritos extends HiveObject {
  @HiveField(0)
  double id;

  Favoritos({
    required this.id,
  });
}
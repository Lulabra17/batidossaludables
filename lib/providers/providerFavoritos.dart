import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';



class ProviderFavoritos{

  late Box box;

  Future<bool> initBox() async {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    box = await Hive.openBox('Favoritos');
    return true;
  }

  Future<bool> addFavoritos(var FavoritosAdapter) async {

    await box.add(FavoritosAdapter);
    return true;
  }

  Future<bool> createFavoritos(var FavoritosAdapter) async {

    await box.addAll(FavoritosAdapter); //Se pasa un iterable que contiene n variables a almacenar
    return true;
  }

  Future<bool> obtenerFavoritos(var index) async {

    await box.getAt(index); //Se pasa un iterable que contiene n variables a almacenar
    return true;
  }
  Map<dynamic,dynamic> readFavoritos(){

    Map<dynamic,dynamic> favoritosMap = box.toMap(); //Para mejor control, se retorna un mapa
    return favoritosMap;
  }

  Future<bool> deleteFavoritos(int index) async {

    await box.deleteAt(index);
    return true;
  }

  Future<bool> updateFavoritos(int index, var batidoFavorito) async {

    await box.putAt(index, batidoFavorito);
    return true;
  }

  dispose() => box.close();
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favoritos.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritosAdapter extends TypeAdapter<Favoritos> {
  @override
  final int typeId = 0;

  @override
  Favoritos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favoritos(
      id: fields[0] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Favoritos obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

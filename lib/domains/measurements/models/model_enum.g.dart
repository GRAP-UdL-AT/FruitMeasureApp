// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelAdapter extends TypeAdapter<Model> {
  @override
  final typeId = 67;

  @override
  Model read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Model.fruto;
      case 1:
        return Model.corimbo;
      case 2:
        return Model.caixa;
      default:
        return Model.fruto;
    }
  }

  @override
  void write(BinaryWriter writer, Model obj) {
    switch (obj) {
      case Model.fruto:
        writer.writeByte(0);
      case Model.corimbo:
        writer.writeByte(1);
      case Model.caixa:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

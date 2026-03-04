// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      userName: fields[1] as String,
      email: fields[2] as String,
      deletePhotosAfterMeasure: fields[3] as bool,
      supportDistance: (fields[4] as num).toDouble(),
      disclaimerAccepted: fields[5] == null ? false : fields[5] as bool,
      preferredLanguage: fields[6] as String?,
      confidenceThreshold:
          fields[7] == null ? 0.80 : (fields[7] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.deletePhotosAfterMeasure)
      ..writeByte(4)
      ..write(obj.supportDistance)
      ..writeByte(5)
      ..write(obj.disclaimerAccepted)
      ..writeByte(6)
      ..write(obj.preferredLanguage)
      ..writeByte(7)
      ..write(obj.confidenceThreshold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlotAdapter extends TypeAdapter<Plot> {
  @override
  final typeId = 1;

  @override
  Plot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plot(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String?,
      farmer: fields[4] as String,
      creationDate: fields[5] as DateTime,
      modificationDate: fields[6] as DateTime,
      plantationDate: fields[7] as DateTime,
      variety: fields[8] as String,
      lat: (fields[9] as num?)?.toDouble(),
      lng: (fields[10] as num?)?.toDouble(),
      sourceId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plot obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.farmer)
      ..writeByte(5)
      ..write(obj.creationDate)
      ..writeByte(6)
      ..write(obj.modificationDate)
      ..writeByte(7)
      ..write(obj.plantationDate)
      ..writeByte(8)
      ..write(obj.variety)
      ..writeByte(9)
      ..write(obj.lat)
      ..writeByte(10)
      ..write(obj.lng)
      ..writeByte(11)
      ..write(obj.sourceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeasurementAdapter extends TypeAdapter<Measurement> {
  @override
  final typeId = 2;

  @override
  Measurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Measurement(
      id: fields[0] as String,
      plotId: fields[1] as String,
      model: fields[2] as Model?,
      name: fields[6] as String?,
      observations: fields[5] as String,
      creationDate: fields[3] as DateTime,
      modificationDate: fields[4] as DateTime,
      sourceId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Measurement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plotId)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.creationDate)
      ..writeByte(4)
      ..write(obj.modificationDate)
      ..writeByte(5)
      ..write(obj.observations)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.sourceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final typeId = 3;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      id: fields[0] as String,
      measurementId: fields[1] as String,
      captureDate: fields[2] as DateTime,
      creationDate: fields[12] as DateTime,
      latitude: (fields[3] as num?)?.toDouble(),
      longitude: (fields[4] as num?)?.toDouble(),
      imagePath: fields[9] as String?,
      galleryPath: fields[13] as String?,
      originalImagePath: fields[14] as String?,
      sourceId: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.measurementId)
      ..writeByte(2)
      ..write(obj.captureDate)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(12)
      ..write(obj.creationDate)
      ..writeByte(13)
      ..write(obj.galleryPath)
      ..writeByte(14)
      ..write(obj.originalImagePath)
      ..writeByte(15)
      ..write(obj.sourceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DetectionAdapter extends TypeAdapter<Detection> {
  @override
  final typeId = 4;

  @override
  Detection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Detection(
      id: fields[0] as String,
      photoId: fields[1] as String,
      confidence: (fields[2] as num).toDouble(),
      cls: fields[3] as String,
      x1: (fields[4] as num).toDouble(),
      y1: (fields[5] as num).toDouble(),
      x2: (fields[6] as num).toDouble(),
      y2: (fields[7] as num).toDouble(),
      caliber: (fields[8] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Detection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.photoId)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.cls)
      ..writeByte(4)
      ..write(obj.x1)
      ..writeByte(5)
      ..write(obj.y1)
      ..writeByte(6)
      ..write(obj.x2)
      ..writeByte(7)
      ..write(obj.y2)
      ..writeByte(8)
      ..write(obj.caliber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

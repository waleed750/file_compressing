// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_image_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheImageModelsAdapter extends TypeAdapter<CacheImageModels> {
  @override
  final int typeId = 1;

  @override
  CacheImageModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheImageModels(
      name: fields[0] as String,
      file: fields[1] as Uint8List,
      date: fields[2] as DateTime,
      path: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CacheImageModels obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.file)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheImageModelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheImageModels _$CacheImageModelsFromJson(Map<String, dynamic> json) =>
    CacheImageModels(
      name: json['cache_name'] as String,
      file: _uint8ListFromJson(json['cache_file'] as String),
      date: DateTime.parse(json['cache_date'] as String),
      path: json['cache_path'] as String,
    );

Map<String, dynamic> _$CacheImageModelsToJson(CacheImageModels instance) =>
    <String, dynamic>{
      'cache_name': instance.name,
      'cache_file': _uint8ListToJson(instance.file),
      'cache_date': instance.date.toIso8601String(),
      'cache_path': instance.path,
    };

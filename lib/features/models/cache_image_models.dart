// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'cache_image_models.g.dart';

@HiveType(typeId: 1) // typeId should be unique for each model
@JsonSerializable()
class CacheImageModels {
  @HiveField(0) // unique id for each field
  @JsonKey(name: 'cache_name')
  String name;

  @HiveField(1)
  @JsonKey(
    name: 'cache_file',
    fromJson: _uint8ListFromJson,
    toJson: _uint8ListToJson,
  )
  Uint8List file;

  @HiveField(2)
  @JsonKey(name: 'cache_date')
  DateTime date;

  @HiveField(3)
  @JsonKey(name: 'cache_path')
  String path;

  CacheImageModels(
      {required this.name,
      required this.file,
      required this.date,
      required this.path});
}

/// Custom serialization for Uint8List
Uint8List _uint8ListFromJson(String base64String) => base64Decode(base64String);

String _uint8ListToJson(Uint8List data) => base64Encode(data);

import 'package:file_compressing/features/models/cache_image_models.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'my_app.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CacheImageModelsAdapter()); //add TypeAdapater
  runApp(const MyApp());
}

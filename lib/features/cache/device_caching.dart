// import 'dart:typed_data';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// import 'abstract_cache.dart';

// class NonWebFileStorage implements FileStorage {
//   @override
//   Future<void> saveFile(String name, Uint8List data) async {
//     final cacheManager = DefaultCacheManager();
//     await cacheManager.putFile(name, data, fileExtension: 'png');
//   }

//   @override
//   Future<Map<String, dynamic>?> getFile(String name) async {
//     final cacheManager = DefaultCacheManager();
//     final fileInfo = await cacheManager.getFileFromCache(name);
//     if (fileInfo != null) {
//       final fileBytes = await fileInfo.file.readAsBytes();
//       return {
//         'name': name,
//         'bytes': fileBytes,
//       };
//     }
//     return null;
//   }

//   @override
//   void removeFile(String name) {
//     final cacheManager = DefaultCacheManager();
//     cacheManager.removeFile(name);
//   }
// }

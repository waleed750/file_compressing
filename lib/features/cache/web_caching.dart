import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_compressing/features/models/cache_image_models.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// import 'package:hive/hive.dart';

class WebCaching {
  static const String _boxname = 'web_cache';

  static Future<Box<CacheImageModels>> get _box async {
    try {
      return await Hive.openBox<CacheImageModels>(
        _boxname,
      );
    } catch (e) {
      if (await Hive.boxExists(
        _boxname,
      )) {
        await Hive.deleteBoxFromDisk(_boxname);
        return Hive.openBox<CacheImageModels>(_boxname);
      } else {
        return Hive.openBox<CacheImageModels>(_boxname);
      }
    }
  }

  static Future<void> cleanUpExpiredData(dynamic _) async {
    var cacheBox = await _box;
    log('Initiatlized');
    DateTime currentTime = DateTime.now();
    int count = 0;
    // Loop through all the records and delete expired ones
    for (var i = 0; i < cacheBox.values.length; i++) {
      var cacheData = cacheBox.getAt(i);
      if (cacheData != null) {
        // Check if the record is older than the specified days
        if (currentTime.difference(cacheData.date).inSeconds > 3) {
          await cacheBox.deleteAt(i); // Delete expired record
          count++;
        }
      }
    }
    log('Cleaned : $count , current length : ${cacheBox.length}');
  }

  static Future<void> saveFile(String name, XFile data) async {
    var box = await _box;
    if (box.containsKey(name)) {
      // log('Already exists');
      return;
    }
    var bytes = await data.readAsBytes();
    late final String path;
    if (kIsWeb || kIsWasm) {
      path = data.path;
    } else {
      // For non-web/WASM (iOS, Android, etc.), save the file to the device's temp directory
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = p.join(tempDir.path, name);

      // Save the file to the temporary directory
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(bytes);

      // Save the file details in Hive
      path = tempFilePath;
    }
    await box.put(
        name,
        CacheImageModels(
            name: name, file: bytes, date: DateTime.now(), path: path));
    // log('message $int');
  }

  //read
  static Future<XFile?> getFile(String name) async {
    var box = await _box;
    final file = box.get(name);
    // final file = box.values.toList().firstWhere(
    //       (element) => element.name == name,
    //       orElse: () => CacheImageModels(name: name, file: Uint8List(0)),
    //     );
    if (file != null) {
      return XFile.fromData(file.file,
          name: name, mimeType: file.file._getFileType().name, path: file.path);
    }
    return null;
  }

  static Future<void> removeFile(String name) async {
    var box = await _box;
    return box.delete(name);
  }
}

enum FileMediaType { image, video, any }

extension Uint8ListFileTypeChecker on Uint8List {
  /// Determines the file type by analyzing the file's signature (magic numbers)
  FileMediaType _getFileType() {
    if (isEmpty) return FileMediaType.any;

    // Get the file signature (magic numbers)
    final header = sublist(0, 4)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ')
        .toUpperCase();

    // Video file signatures
    const videoSignatures = [
      '00 00 00 18', '66 74 79 70', // MP4
      '1a 45 df a3', // MKV
      '4f 67 67 53', // OGG Video
      '52 49 46 46 41 56 49 20', // AVI
      '30 26 b2 75', // WMV
      '46 4c 56', // FLV
      '1a 45 df a3', // WebM
      '00 00 00 20', '00 00 00 1c' // MOV
    ];

    // Image file signatures (magic numbers)
    const imageSignatures = [
      'FF D8 FF E0',
      'FF D8 FF E0 00', // JPEG/JPG (Start of Image with APP0 marker)
      'FF D8 FF E1', // JPEG/JPG (Start of Image with APP1 marker)
      'FF D8 FF E2', // JPEG/JPG (Start of Image with APP2 marker)
      'FF D8 FF E3', // JPEG/JPG (Start of Image with APP3 marker)
      'FF D8 FF E8', // JPEG/JPG (Start of Image with APP8 marker)
      'FF D8 FF DB', // JPEG/JPG (Start of Image with DQT marker)
      '89 50 4E 47', // PNG
      '47 49 46 38', // GIF
      '42 4D', // BMP
      '49 49 2A 00', // TIFF (Little Endian)
      '4D 4D 00 2A', // TIFF (Big Endian)
      '52 49 46 46 00 00 00 00 57 45 42 50', // WEBP
      '66 74 79 70 68 65 69 66', // HEIF
      '00 00 01 00', // ICO (Icon)
      '00 00 00 0C 6A 50 20 20', // JPEG2000 (JP2)
      '1F 8B 08', // PNG (compressed)
      '52 49 46 46', // RIFF (for BMP, WEBP, etc.)
      '00 00 01 00', // ICO (Icon format)
      '4F 46 53 0A', // OpenEXR
      '44 49 43 4D 50', // DICOM (Medical Imaging)
    ];

    // Check video file signatures
    if (videoSignatures.any((signature) => header.startsWith(signature))) {
      return FileMediaType.video;
    }

    // Check image file signatures
    if (imageSignatures.any((signature) => header.startsWith(signature))) {
      return FileMediaType.image;
    }
    log('Unknown file type: $header');
    // Default fallback
    return FileMediaType.any;
  }

  FileMediaType get bytesFileType => _getFileType();
}

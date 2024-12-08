import 'dart:developer';
import 'dart:io';
import 'package:file_compressing/features/cache/web_caching.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageBeforeCompression;
  String? imageName;
  VideoPlayerController? controller;
  VideoPlayerController? compressController;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () async {
                try {
                  final picker = await FilePicker.platform.pickFiles(
                    allowCompression: true,
                    type: FileType.media,
                    allowMultiple: false,
                  );

                  if (picker != null) {
                    final xFile = picker.files.first.xFile;

                    final fileName = "${picker.files.first.xFile.name}";

                    // Save file bytes and name using the platform-specific storage
                    await WebCaching.saveFile(fileName, xFile);
                    // compute(WebCaching.cleanUpExpiredData, null);

                    // Retrieve the file from platform-specific storage
                    final cachedFile = await WebCaching.getFile(fileName);
                    if (cachedFile != null && cachedFile.mimeType! == 'image') {
                      imageBeforeCompression = await cachedFile.readAsBytes();
                      imageName = fileName;
                      setState(() {});
                    } else if (cachedFile != null &&
                        cachedFile.mimeType! == 'video') {
                      if (kIsWeb || kIsWasm) {
                        log('path : ${cachedFile.path}');
                        controller = VideoPlayerController.networkUrl(
                            Uri.parse(cachedFile.path))
                          ..initialize().then((value) {
                            controller!.play();
                            setState(() {});
                          }).onError((error, stackTrace) {
                            log(error.toString());
                          });
                      } else {
                        final tempfile = File(cachedFile.path);

                        // MediaInfo? mediaInfo =
                        //     await VideoCompress.compressVideo(
                        //   cachedFile.path,
                        //   quality: VideoQuality.DefaultQuality,
                        //   deleteOrigin: false, // It's false by default
                        // );
                        // if (mediaInfo != null) {
                        // compressController =
                        //     VideoPlayerController.file(File(mediaInfo.path!))
                        //       ..initialize().then((value) {
                        //         // compressController!.play();
                        //         setState(() {});
                        //       }).onError((error, stackTrace) {
                        //         log(error.toString());
                        //       });
                        // controller =
                        //     VideoPlayerController.file(mediaInfo.file!)
                        //       ..initialize().then((value) {
                        //         controller!.play();
                        //         setState(() {});
                        //       }).onError((error, stackTrace) {
                        //         log(error.toString());
                        //       });
                        // }
                        // final mediaInfo =
                        //     await FlutterFileCompressor.compressFile(
                        //   filePath: tempfile.path,
                        //   quality: 70, //percent
                        //   compressionType:
                        //       CompressionType.video, //CompressionType.video
                        // );
                        // log('Type ')
                        final Stopwatch stopwatch = Stopwatch()..start();
                        MediaInfo? mediaInfo =
                            await VideoCompress.compressVideo(
                          tempfile.path,
                          quality: VideoQuality.Res640x480Quality,
                          deleteOrigin: false, // It's false by default
                        );
                        controller = VideoPlayerController.file(tempfile)
                          ..initialize().then((value) async {
                            await controller!.setVolume(0);
                            await controller!.play();
                            setState(() {});
                          }).onError((error, stackTrace) {
                            log(error.toString());
                          });
                        stopwatch.stop();
                        log('Time Taken : ${stopwatch.elapsed.inSeconds} sec -> Before Compression : ${await cachedFile.length()} , After Compression : ${mediaInfo?.filesize}');
                      }
                    }
                  }
                } catch (e) {
                  log('Error picking file: $e');
                }
              },
              child: const Text("Pick Image"),
            ),
            if (imageBeforeCompression != null && imageName != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.memory(imageBeforeCompression!),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    imageName!,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getSizeInReadableFormat(imageBeforeCompression!),
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
            if (controller != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AspectRatio(
                      aspectRatio: 16 / 9, child: VideoPlayer(controller!)),
                  const SizedBox(height: 10),
                  if (compressController != null)
                    AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayer(compressController!)),
                ],
              )
          ],
        ),
      ),
    );
  }

  String getSizeInReadableFormat(Uint8List data) {
    int sizeInBytes = data.length;
    double sizeInKB = sizeInBytes / 1024; // Convert bytes to KB
    double sizeInMB = sizeInKB / 1024; // Convert KB to MB

    // Return the appropriate size format based on the value.
    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else {
      return '${sizeInKB.toStringAsFixed(2)} KB';
    }
  }
}

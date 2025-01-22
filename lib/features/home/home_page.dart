import 'dart:developer';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:file_compressing/features/cache/web_caching.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:path/path.dart';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () async {
                  try {
                    final picker = await FilePicker.platform.pickFiles(
                      allowCompression: true,
                      type: FileType.video,
                      allowMultiple: false,
                      // compressionQuality: 20,
                    );

                    if (picker != null) {
                      final xFile = picker.files.first.xFile;
                      final url =
                          'https://storage.nearay.net/icons%2Fmapmarker%2Fevent_icon.png';
                      final cache = CacheManager(Config(
                        url,
                        stalePeriod: const Duration(days: 1),
                      ));

                      // final fileName = "${picker.files.first.xFile.name}";

                      // Save file bytes and name using the platform-specific storage
                      // await WebCaching.saveFile(fileName, xFile);
                      // compute(WebCaching.cleanUpExpiredData, null);
                      // final getFile = await cache.getSingleFile(url);

                      // Retrieve the file from platform-specific storage
                      final bytes = await xFile.readAsBytes();
                      final cachedFile =
                          XFile.fromData(bytes, mimeType: 'video');
                      if (cachedFile != null &&
                          (cachedFile.mimeType ?? "") == 'image') {
                        imageBeforeCompression = await cachedFile.readAsBytes();
                        imageName = '${xFile.path}\n${cachedFile.path}';
                        setState(() {});
                      } else if (cachedFile != null &&
                          (cachedFile.mimeType ?? "") == 'video') {
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
                          // MediaInfo? mediaInfo =
                          //     await VideoCompress.compressVideo(
                          //   tempfile.path,
                          //   quality: VideoQuality.Res640x480Quality,
                          //   deleteOrigin: false, // It's false by default
                          // );
                          FFmpegKitConfig.enableLogCallback(
                            (lo) => log(lo.getMessage()),
                          );
                          final directory = await getExternalStorageDirectory();
                          final temp = await getTemporaryDirectory();
                          log('Directory Path : ${directory!.path}');
                          final String fullTemporaryPath = join(directory!.path,
                              "${const Uuid().v1()}.${xFile.name.split('.').last}");
                          File? fileAfterCompressing;
                          // ignore: unused_local_variable
                          final commandWorking =
                              '-i ${xFile.path} -c:v libx264 -crf 23 -preset fast -vf "scale=trunc(oh*a/2)*2:1080" -c:a aac -b:a 128k $fullTemporaryPath';
                          final testCommands =
                              '-i ${xFile.path} -c:v libx264 -crf 21 -preset fast  -c:a aac -b:a 128k $fullTemporaryPath';
                          FFmpegKit.execute(testCommands).then((session) async {
                            final returnCode = await session.getReturnCode();

                            if (returnCode?.isValueSuccess() ?? false) {
                              // SUCCESS
                              fileAfterCompressing = File(fullTemporaryPath);
                              final file2 = File(xFile.path);
                              log('success : ${fileAfterCompressing!.lengthSync()}',
                                  name: 'FFMPEG');
                              controller = VideoPlayerController.file(file2,
                                  videoPlayerOptions:
                                      VideoPlayerOptions(mixWithOthers: true))
                                ..initialize().then((value) async {
                                  await controller!.setVolume(1);
                                  // await controller!.play();
                                  setState(() {});
                                }).onError((error, stackTrace) {
                                  log(error.toString());
                                });
                              compressController = VideoPlayerController.file(
                                  fileAfterCompressing!,
                                  videoPlayerOptions: VideoPlayerOptions(
                                    mixWithOthers: true,
                                  ))
                                ..initialize().then((value) async {
                                  await compressController!.setVolume(1);
                                  // await compressController!.play();
                                  setState(() {});
                                }).onError((error, stackTrace) {
                                  log(error.toString());
                                });
                              stopwatch.stop();
                              log('Time Taken : ${stopwatch.elapsed.inSeconds} sec -> Before Compression : ${await cachedFile.length()} , After Compression : ${fileAfterCompressing?.lengthSync()}');
                            } else if (returnCode?.isValueCancel() ?? false) {
                              // CANCEL
                              log('cancel :  ${returnCode?.getValue()}',
                                  name: 'FFMPEG');
                            } else {
                              // ERROR
                              log('error : ${returnCode?.getValue()}',
                                  name: 'FFMPEG');
                              log('error : ${returnCode?.getValue()}',
                                  name: 'FFMPEG');
                            }
                          });
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller!.value.isPlaying
                            ? controller!.pause()
                            : controller!.play();
                      },
                      child: GestureDetector(
                        // onTap: () {
                        // showCupertinoDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return SizedBox.expand(
                        //         child: FittedBox(
                        //           fit: BoxFit.cover,
                        //           child: SizedBox(
                        //             height: controller!.value.size.height,
                        //             width: controller!.value.size.width,
                        //             child: AspectRatio(
                        //                 aspectRatio:
                        //                     controller!.value.aspectRatio,
                        //                 child: VideoPlayer(controller!)),
                        //           ),
                        //         ),
                        //       );
                        //     });
                        // },
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller!.value.size.width,
                              height: controller!.value.size.height,
                              child: AspectRatio(
                                  aspectRatio: controller!.value.aspectRatio,
                                  child: VideoPlayer(controller!)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (compressController != null)
                      GestureDetector(
                        onTap: () {
                          compressController!.value.isPlaying
                              ? compressController!.pause()
                              : compressController!.play();
                        },
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: compressController!.value.size.width,
                              height: compressController!.value.size.height,
                              child: AspectRatio(
                                  aspectRatio:
                                      compressController!.value.aspectRatio,
                                  child: VideoPlayer(compressController!)),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
            ],
          ),
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

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'scan.dart';

late final List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const EdgeDetectionApp());
}

class EdgeDetectionApp extends StatefulWidget {
  const EdgeDetectionApp({super.key});

  @override
  State<EdgeDetectionApp> createState() => _EdgeDetectionAppState();
}

class _EdgeDetectionAppState extends State<EdgeDetectionApp> {
  CameraImage? _image;
  late final CameraController _controller;

  @override
  void initState() {
    super.initState();

    () async {
      _controller = CameraController(
        cameras
            .where(
                (element) => element.lensDirection == CameraLensDirection.back)
            .first,
        ResolutionPreset.low,
        enableAudio: false,
      );
      await _controller.initialize();
      _controller.startImageStream((image) {
        setState(() => _image = image);
      });
    }();
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Image convertYUV420toImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(
      width: width,
      height: height,
    ); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data?.setPixelRgb(x, y, r, g, b);
      }
    }

    imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0);
    final png = pngEncoder.encode(img);
    return Image.memory(png);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: _image != null
              ? convertYUV420toImageColor(_image!)
              : Placeholder(),
        ),
      ),
    );
  }
}

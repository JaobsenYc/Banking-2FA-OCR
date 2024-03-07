/* import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';
import 'package:safe_transfer/data/transfer_data.dart';

class QrScanWidget extends StatefulWidget {
  final Function(TransferData) onScanCompleted;

  const QrScanWidget({Key? key, required this.onScanCompleted}) : super(key: key);

  @override
  State<QrScanWidget> createState() => _QrScanState();
}

class _QrScanState extends State<QrScanWidget> {
  var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 0, // Number of method calls to be displayed
    ),
  );

  CameraController? cameraController;
  StreamSubscription? decoderSubscription;
  List<CameraDescription> cameras = [];
  String qrValue = '';
  String ocrValue = '';
  ScanKitDecoder decoder = ScanKitDecoder(photoMode: false, parseResult: false);
  TextRecognizer textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  bool finishQr = false;
  bool finishOcr = false;
  bool startOcr = false;

  @override
  void initState() {
    availableCameras().then((val) {
      cameras = val;
      if (cameras.isNotEmpty) {
        cameraController = CameraController(cameras[0], ResolutionPreset.max);
        cameraController!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          cameraController!.startImageStream(onLatestImageAvailable);
          setState(() {});
        });
      }
    });

    decoderSubscription = decoder.onResult.listen((event) async {
      if (event is ResultEvent && event.value.isNotEmpty) {
        logger.d('qr scan finish');

        decoderSubscription!.pause();
        // await stopScan();
        finishQr = true;
        qrValue = event.value.originalValue;
      } else if (event is ZoomEvent) {
        /// set zoom value
      }
    });
    super.initState();
  }

  Future<void> stopScan() async {
    logger.d('stop scan');
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      // Pause the camera preview
      await cameraController!.pausePreview();
      await cameraController!.stopImageStream();
    }
  }

  @override
  void dispose() {
    decoderSubscription?.cancel();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (cameraController != null &&
        cameraController!.value.isInitialized)
        ? CameraPreview(cameraController!)
        : const Placeholder();
  }

  void onLatestImageAvailable(CameraImage image) async {
    if (!finishQr) {
      await imageQrScan(image);
    }

    if (!finishOcr && !startOcr) {
      await imageOcr(image);
    }

    if (finishOcr && finishQr) {
      await stopScan();
      handleScanFinish();
    }
  }

  void handleScanFinish() {
    TransferData data = TransferData(amount: '8,848', name: 'Danny Xing', sortCode: '12-34-56', accountNumber: '1234567', id: 'A4D788ED');
    widget.onScanCompleted(data);
  }

  Future<void> imageQrScan(CameraImage image) async {
    logger.d('start qr scan ${image.hashCode}');

    if (image.planes.length == 1 &&
        image.format.group == ImageFormatGroup.bgra8888) {
      await decoder.decode(image.planes[0].bytes, image.width, image.height);
    } else if (image.planes.length == 3) {
      Uint8List y = image.planes[0].bytes;
      Uint8List u = image.planes[1].bytes;
      Uint8List v = image.planes[2].bytes;

      Uint8List combined = Uint8List(y.length + u.length + v.length);
      combined.setRange(0, y.length, y);
      combined.setRange(y.length, y.length + u.length, u);
      combined.setRange(y.length + u.length, y.length + u.length + v.length, v);
      await decoder.decodeYUV(combined, image.width, image.height);
    }
  }

  imageOcr(CameraImage image) async {
    if (startOcr) {
      return;
    }

    logger.d('start ocr ${image.hashCode}');
    startOcr = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final camera = cameras[0];
    final imageRotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(
      image.format.raw,
    );
    if (inputImageFormat == null) return;

    final planeData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: planeData,
    );

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    startOcr = false;

    final lines = recognizedText.text.split('\n');

    for (var element in lines) {
      if (element.contains('ID:')) {
        ocrValue = element;
        finishOcr = true;
      }
    }

    if (finishOcr) {
      logger.d('ocr finish\n${recognizedText.text}');
    } else {
      logger.d('ocr failed\n${recognizedText.text}');
    }
  }
}

 */
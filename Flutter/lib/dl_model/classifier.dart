import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io' as io;
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class Classifier {
  Classifier();

  classifyImage(PickedFile image) async {
    final io.File _file = io.File(image.path);
    img.Image? imageTemp = img.decodeImage(_file.readAsBytesSync());

    if (imageTemp != null) {
      img.Image resizedImg = img.copyResize(imageTemp, height: 28, width: 28);
      var imgBytes = resizedImg.getBytes();
      var imgAsList = imgBytes.buffer.asUint8List();
      return getPred(imgAsList);
    } else {
      // Handle the case where image decoding fails
    }

  }

  classifyDrawing(List<Offset?> points) async{
    var picture;
    var imgAsList;
    if(points != null) {
      picture = toPicture(points);
    }
    final image = await picture.toImage(28, 28);
    ByteData? imgBytes = await image.toByteData();

    if (imgBytes != null) {
      imgAsList = imgBytes.buffer.asUint8List();
    } else {
    }

    return getPred(imgAsList);
  }

  Future<int> getPred(Uint8List imgAsList) async {
    List resultBytes = List.filled(28 * 28, 0);

    int index = 0;
    for(int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i+1];
      final b = imgAsList[i+2];

      resultBytes[index] = ((r+g+b)/3.0)/255.0;
      index++;
    }

    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1*10, 0).reshape([1, 10]);

    InterpreterOptions interpreterOptions = InterpreterOptions();

    try {
      Interpreter interpreter = await Interpreter.fromAsset("assets/model.tflite",
          options: interpreterOptions);
      interpreter.run(input, output);
    } catch (e) {
      print('Error loading or running model: ' + e.toString());
    }

    double highestProb = 0;
    int digitPred = -1;

    for(int i = 0; i < output[0].length; i++) {
      if(output[0][i] > highestProb) {
        highestProb = output[0][i];
        digitPred = i;
      }
    }
    return digitPred;
  }
}

ui.Picture toPicture(List<Offset?> points){
  final _whitePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.white
    ..strokeWidth = 16.0;

  final _bgPaint = Paint()..color = Colors.black;
  final _canvasCullRect = Rect.fromPoints(Offset(0, 0),
    Offset(28.0, 28.0));
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, _canvasCullRect)
    ..scale(28/300);

  canvas.drawRect(Rect.fromLTWH(0, 0, 28, 28), _bgPaint);

  for(int i = 0; i < points.length - 1; i++) {
    final Offset? point1 = points[i];
    final Offset? point2 = points[i + 1];

    // Check if both points are not null before drawing the line
    if (point1 != null && point2 != null) {
      canvas.drawLine(point1, point2, _whitePaint);
    }
  }

  return recorder.endRecording();
}
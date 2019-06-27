import 'dart:io';
import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'face_detector_painter.dart';

void main() {
  /*
  final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(
      '/Users/b556585/Documents/projects/flutter/face_test/assets/people.jpg');

  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true));
  faceDetector.processImage(visionImage).then((faces) {
    for (Face face in faces) {
      print(face.toString());
    }
    faceDetector.close();
    
  }).catchError((error) => print(error));
  */
  runApp(MaterialApp(home: Faces()));
}

class Faces extends StatefulWidget {
  Faces({Key key}) : super(key: key);

  _FacesState createState() => _FacesState();
}

class _FacesState extends State<Faces> {
  File _imageFile;
  Size _imageSize;
  dynamic _scanResults;

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
        FaceDetectorOptions(
            enableClassification: true,
            enableLandmarks: true,
            enableTracking: true));
    final dynamic results =
        await faceDetector.processImage(visionImage) ?? <dynamic>[];
    setState(() {
      _scanResults = results;
    });
    faceDetector.close();
  }

  CustomPaint _buildResults(Size imageSize, dynamic results) {
    CustomPainter painter = FaceDetectorPainter(_imageSize, results);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.file(_imageFile).image,
          fit: BoxFit.fill,
        ),
      ),
      child: _imageSize == null || _scanResults == null
          ? const Center(
              child: Text(
                'Scanning...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : _buildResults(_imageSize, _scanResults),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FaceApp'),
      ),
      body: _imageFile == null
          ? const Center(child: Text('No image selected'))
          : _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getAndScanImage,
        tooltip: 'Pick image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

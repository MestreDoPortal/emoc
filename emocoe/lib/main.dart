import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(FaceDetectionApp());
}

class FaceDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _image;
  final picker = ImagePicker();

  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableClassification: true),
  );

  String _faceMessage = "Nenhum rosto detectado";

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _faceMessage = "Processando...";
      });
      await _detectFaces();
    }
  }

  Future<void> _detectFaces() async {
    if (_image == null) return;

    final inputImage = InputImage.fromFile(_image!);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      String message = "Rostos detectados: ${faces.length}\n";

      for (Face face in faces) {
        double? smilingProbability = face.smilingProbability;

        String emotion = "🤔 Indefinido";

        if (smilingProbability != null) {
          if (smilingProbability > 0.7) {
            emotion = "😀 Feliz";
          } else if (smilingProbability < 0.3) {
            emotion = "😢 Triste";
          }
        }

        message += "$emotion\n";
      }

      setState(() {
        _faceMessage = message;
      });
    } else {
      setState(() {
        _faceMessage = "Nenhum rosto detectado";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detector de Emoções')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Image.file(_image!, height: 300)
              : Icon(Icons.image, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            _faceMessage,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _getImage(ImageSource.camera),
                child: Text('Tirar Foto'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _getImage(ImageSource.gallery),
                child: Text('Escolher da Galeria'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

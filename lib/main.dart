import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PlantDiseaseDetector(),
    );
  }
}

class PlantDiseaseDetector extends StatefulWidget {
  const PlantDiseaseDetector({super.key});

  @override
  State<PlantDiseaseDetector> createState() => _PlantDiseaseDetectorState();
}

class _PlantDiseaseDetectorState extends State<PlantDiseaseDetector> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _analysisResult = "Select an image to analyze";
  final String _geminiApiKey = "AIzaSyBjuRLh2nXSz9yTUFrKIS7EbhAT8eGmeVw"; // Replace with your actual API key

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _analysisResult = "Image selected. Tap 'Analyze' to get results.";
      } else {
        _analysisResult = "No image selected.";
      }
    });
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      setState(() {
        _analysisResult = "Please select an image first.";
      });
      return;
    }

    setState(() {
      _analysisResult = "Analyzing...";
    });

    try {
      // Replace with the actual Gemini API endpoint for image analysis
      // This is a placeholder URL and needs to be updated with the correct endpoint
      final uri = Uri.parse('YOUR_GEMINI_API_ENDPOINT_HERE');
      final request = http.MultipartRequest('POST', uri)
        ..headers['x-goog-api-key'] = _geminiApiKey
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // Process the JSON response from Gemini API
        // The structure of the response depends on the specific Gemini model/endpoint used
        // This is a placeholder for extracting relevant information
        String disease = jsonResponse['disease'] ?? 'Unknown disease';
        String fertilizer = jsonResponse['fertilizer'] ?? 'Unknown fertilizer';
        String solution = jsonResponse['solution'] ?? 'No solution provided';

        setState(() {
          _analysisResult = """
Disease: $disease
Required Fertilizer: $fertilizer
Homemade Solution: $solution
""";
        });
      } else {
        final errorBody = await response.stream.bytesToString();
        setState(() {
          _analysisResult = "Error analyzing image: ${response.statusCode}\n$errorBody";
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detector'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!, height: 300),
              const SizedBox(height: 20),
              Text(
                _analysisResult,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: const Text('Take Photo'),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Pick from Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _analyzeImage,
                child: const Text('Analyze'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

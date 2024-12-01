import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SpeechToText _speechToText = SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = "";
  String _translatedText = "";

  // Google Translate API (change this to your actual API key)
  final String _apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
  
  // Function to start speech recognition
  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speechToText.stop();
    }
  }

  // Function to translate the recognized text
  Future<void> _translateText(String text) async {
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'q': text,
        'target': 'es', // Change to the target language code, e.g., 'es' for Spanish
        'key': _apiKey,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _translatedText = data['data']['translations'][0]['translatedText'];
      });
    } else {
      print('Translation failed');
    }
  }

  // Function to speak the translated text
  void _speakTranslatedText() async {
    await _flutterTts.speak(_translatedText);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Voice Translation App')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _toggleListening,
                child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              ),
              SizedBox(height: 16),
              Text("Recognized Text: $_recognizedText"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_recognizedText.isNotEmpty) {
                    _translateText(_recognizedText);
                  }
                },
                child: Text('Translate'),
              ),
              SizedBox(height: 16),
              Text("Translated Text: $_translatedText"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _speakTranslatedText,
                child: Text('Speak Translated Text'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

# Flutter Integration with File Upload API

## Overview
This document explains how to integrate the Flutter app with the updated backend API that now supports direct file uploads for audio processing.

## Required Flutter Packages

```yaml
dependencies:
  # HTTP requests
  http: ^1.1.0
  # File picking
  file_picker: ^5.3.3
  # Audio recording
  record: ^4.4.4
  # HTTP multipart requests for file uploads
  http_parser: ^4.0.2
  # Path utilities
  path: ^1.8.3
  # Permissions
  permission_handler: ^10.3.0
```

## API Service Implementation

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AudioService {
  final String baseUrl;
  final String token;
  
  AudioService({required this.baseUrl, required this.token});
  
  // Upload audio file directly
  Future<Map<String, dynamic>> uploadAudioFile(
    File audioFile, 
    String language, 
    double? durationSeconds
  ) async {
    final url = Uri.parse('$baseUrl/api/audio/upload-file');
    
    var request = http.MultipartRequest('POST', url);
    
    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });
    
    // Add form fields
    request.fields['language'] = language;
    if (durationSeconds != null) {
      request.fields['duration_seconds'] = durationSeconds.toString();
    }
    
    // Add file
    final fileName = path.basename(audioFile.path);
    final fileExtension = path.extension(fileName).toLowerCase().replaceAll('.', '');
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        audioFile.path,
        contentType: MediaType('audio', fileExtension),
      ),
    );
    
    // Send request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to upload file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }
  
  // Process uploaded file
  Future<Map<String, dynamic>> analyzeAudioFile(
    String fileId, 
    String language, 
    {String? referenceText}
  ) async {
    final url = Uri.parse('$baseUrl/api/audio/analyze-file');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file_id': fileId,
          'language': language,
          if (referenceText != null) 'reference_text': referenceText,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing file: $e');
    }
  }
}
```

## Usage Example

```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingScreen extends StatefulWidget {
  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final AudioService _audioService = AudioService(
    baseUrl: 'http://your-backend-url',
    token: 'your-auth-token',
  );
  
  final _audioRecorder = Record();
  String? _recordingPath;
  bool _isRecording = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _analysisResult;
  
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
    }
  }
  
  Future<void> _startRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${tempDir.path}/audio_$timestamp.m4a';
      
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          path: _recordingPath,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );
        
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  Future<void> _uploadAndAnalyze() async {
    if (_recordingPath == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Upload the file
      final uploadResult = await _audioService.uploadAudioFile(
        File(_recordingPath!),
        'en-US',
        null,  // Duration will be determined by backend
      );
      
      final fileId = uploadResult['_id'];
      
      // Analyze the uploaded file
      final analysisResult = await _audioService.analyzeAudioFile(
        fileId,
        'en-US',
      );
      
      setState(() {
        _analysisResult = analysisResult;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      print('Error processing audio: $e');
      // Show error to user
    }
  }
  
  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      
      if (result != null && result.files.single.path != null) {
        setState(() {
          _isProcessing = true;
          _recordingPath = result.files.single.path;
        });
        
        await _uploadAndAnalyze();
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  child: Text('Start Recording'),
                ),
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : null,
                  child: Text('Stop Recording'),
                ),
                ElevatedButton(
                  onPressed: _pickAndUploadFile,
                  child: Text('Select File'),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Process button
            ElevatedButton(
              onPressed: (_recordingPath != null && !_isRecording && !_isProcessing) 
                ? _uploadAndAnalyze 
                : null,
              child: Text('Analyze Speech'),
            ),
            
            SizedBox(height: 16),
            
            // Processing indicator
            if (_isProcessing)
              CircularProgressIndicator(),
              
            // Results display
            if (_analysisResult != null) ...[
              SizedBox(height: 16),
              Text('Transcription:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_analysisResult!['transcription'] ?? ''),
              
              SizedBox(height: 8),
              Text('Pronunciation Score: ${_analysisResult!['pronunciation']['overall_score']}'),
              
              SizedBox(height: 8),
              Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
              
              // Display pronunciation feedback
              ..._analysisResult!['pronunciation']['improvement_suggestions'].map<Widget>(
                (suggestion) => Text('• $suggestion')
              ).toList(),
              
              // Display language feedback
              if (_analysisResult!['language_feedback']['grammar'].isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Grammar Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._analysisResult!['language_feedback']['grammar'].map<Widget>(
                  (issue) => Text('• ${issue['issue']} → ${issue['correction']}')
                ).toList(),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
```

## Key Integration Points

1. **File Upload**:
   - Use `http.MultipartRequest` for uploading files
   - Set proper content-type for audio files
   - Send additional metadata as form fields

2. **Handling Responses**:
   - After upload, you'll receive the file ID
   - Use the file ID for further processing (transcription, analysis)

3. **Permissions**:
   - Request microphone permissions before recording
   - Handle permission denials gracefully

4. **Error Handling**:
   - Implement proper error handling for network requests
   - Show user-friendly error messages

5. **UI/UX Considerations**:
   - Show loading indicators during processing
   - Display results in a clear, organized manner
   - Provide feedback on upload progress for large files 
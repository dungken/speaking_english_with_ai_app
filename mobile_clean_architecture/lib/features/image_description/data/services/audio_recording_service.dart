import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Service for handling audio recording and transcription for image descriptions
class AudioRecordingService {
  // Singleton pattern
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  /// Check if recording permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start audio recording
  Future<bool> startRecording() async {
    try {
      // Check permissions
      if (!await hasPermission()) {
        debugPrint('Recording permission not granted');
        return false;
      }

      // Generate file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';

      // Configure recording settings
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        bitRate: 128000,
        numChannels: 1,
      );

      // Start recording
      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      debugPrint('Recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  /// Stop audio recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        debugPrint('No active recording to stop');
        return null;
      }

      final path = await _recorder.stop();
      _isRecording = false;
      debugPrint('Recording stopped: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
      }

      // Delete the recorded file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted cancelled recording: $_currentRecordingPath');
        }
        _currentRecordingPath = null;
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  /// Upload audio file and get transcription from API
  Future<TranscriptionResult> transcribeAudio(String audioFilePath) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        throw FileSystemException('Audio file not found', audioFilePath);
      }

      // Prepare multipart request
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.audioToTextEndpoint}');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(ApiConstants.authHeaders);

      // Add audio file
      final audioBytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'audio_file',
        audioBytes,
        filename: 'recording.m4a',
      );
      request.files.add(multipartFile);

      debugPrint('Sending transcription request to: $uri');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Transcription response status: ${response.statusCode}');
      debugPrint('Transcription response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        return TranscriptionResult(
          transcription: jsonData['transcription'] ?? '',
          audioId: jsonData['audio_id'],
          success: jsonData['success'] ?? false,
        );
      } else {
        throw ServerException(
          message: 'Failed to transcribe audio: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Error transcribing audio: ${e.toString()}',
      );
    } finally {
      // Clean up the audio file after upload
      try {
        final file = File(audioFilePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Cleaned up audio file: $audioFilePath');
        }
      } catch (e) {
        debugPrint('Error cleaning up audio file: $e');
      }
    }
  }

  /// Get current recording status
  bool get isRecording => _isRecording;

  /// Dispose resources
  void dispose() {
    _recorder.dispose();
  }
}

/// Result class for transcription response
class TranscriptionResult {
  final String transcription;
  final String? audioId;
  final bool success;

  const TranscriptionResult({
    required this.transcription,
    this.audioId,
    required this.success,
  });

  @override
  String toString() {
    return 'TranscriptionResult(transcription: $transcription, audioId: $audioId, success: $success)';
  }
}

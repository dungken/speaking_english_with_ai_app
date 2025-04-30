// lib/core/services/audio_services.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:record/record.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/platform_checker.dart';
import '../utils/rendering/surface_view_optimizer.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;

  Future<bool> checkPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<void> initialize() async {
    if (!await checkPermission()) {
      throw Exception('Microphone permission not granted');
    }

    // Initialize SurfaceView optimizations on Android to prevent BLASTBufferQueue errors
    if (PlatformChecker.isAndroid) {
      await SurfaceViewOptimizer.initialize();
    }
  }

  Future<void> startRecording() async {
    await initialize();

    if (_isRecording) {
      await stopRecording();
    }

    try {
      // Prepare the renderer for intensive SurfaceView usage on Android
      if (PlatformChecker.isAndroid) {
        SurfaceViewOptimizer.prepareForSurfaceView();
      }

      if (kIsWeb) {
        // For web platform, we don't specify a path
        throw Exception('Recording not supported on web platform');
      } else {
        // For mobile/desktop platforms
        final directory = await getTemporaryDirectory();
        // Ensure we use .wav extension consistently
        final recordingPath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        _currentRecordingPath = recordingPath;

        // Standardize recording configuration across platforms
        // Using settings that are most compatible with speech recognition
        const RecordConfig config = RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000, // 16kHz is standard for speech recognition
          numChannels: 1, // Mono recording is better for speech
        );

        await _audioRecorder.start(
          config,
          path: recordingPath,
        );
      }
      _isRecording = true;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return _currentRecordingPath;
    }

    try {
      await _audioRecorder.stop();
      _isRecording = false;

      // Clean up SurfaceView optimizations on Android
      if (PlatformChecker.isAndroid) {
        SurfaceViewOptimizer.cleanupAfterSurfaceView();
      }

      return _currentRecordingPath;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  bool get isRecording => _isRecording;

  // Updated to match the API which returns both audio_id and transcription
  Future<Map<String, dynamic>> uploadAudioAndGetTranscription(
      String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Audio file not found', filePath);
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.audioToTextEndpoint}'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${ApiConstants.token}',
    });

    // Determine file extension
    final fileExtension = filePath.split('.').last.toLowerCase();
    final mimeType = _getMimeType(fileExtension);

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio_file',
        filePath,
        contentType: mimeType,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          // Parse the response based on the API documentation format
          final responseData = json.decode(response.body);
          final transcription = responseData["transcription"] ?? "";
          final isErrorTranscription =
              transcription.contains("Audio content could not be transcribed");

          return {
            "audio_id": responseData["audio_id"] ?? "",
            "transcription": transcription,
            "success": responseData["success"] ??
                !isErrorTranscription // If success is not provided, use transcription to determine
          };
        } catch (e) {
          throw ServerException(
            message: 'Failed to parse response: $e',
            statusCode: 500,
          );
        }
      } else {
        throw ServerException(
          message:
              'Failed to upload audio: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        message: 'Network error during audio upload: $e',
        statusCode: 503,
      );
    }
  }

  MediaType _getMimeType(String extension) {
    switch (extension) {
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'aac':
      case 'm4a':
        return MediaType('audio', 'aac');
      case 'ogg':
        return MediaType('audio', 'ogg');
      case 'flac':
        return MediaType('audio', 'flac');
      default:
        return MediaType('audio', 'mpeg'); // Default fallback
    }
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;

      // Delete the recorded file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;

      // Clean up SurfaceView optimizations on Android
      if (PlatformChecker.isAndroid) {
        SurfaceViewOptimizer.cleanupAfterSurfaceView();
      }
    }
  }

  void dispose() {
    cancelRecording();
    _audioRecorder.dispose();

    // Make sure we clean up any surface view optimizations on dispose
    if (PlatformChecker.isAndroid) {
      SurfaceViewOptimizer.dispose();
    }
  }
}

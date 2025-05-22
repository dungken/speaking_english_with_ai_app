import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';

/// A service that handles speech audio playback for AI messages.
///
/// This service provides functionality to stream audio from the server,
/// cache it locally for later playback, and manage playback state.
class SpeechAudioService {
  // Singleton pattern
  static final SpeechAudioService _instance = SpeechAudioService._internal();
  factory SpeechAudioService() => _instance;
  SpeechAudioService._internal() {
    _init();
  }

  /// The audio player instance used for playback
  final AudioPlayer _player = AudioPlayer();

  /// A map of message IDs to cached file paths
  final Map<String, String> _cachedFiles = {};

  /// Set to track which messages have been auto-played
  final Set<String> _autoPlayedMessages = {};

  /// Current playing message ID, if any
  String? _currentlyPlayingMessageId;

  /// Maximum number of retry attempts for streaming audio
  static const int maxRetries = 3;

  /// Retry delay in milliseconds (will be multiplied for exponential backoff)
  static const int retryDelay = 500;

  /// Stream that emits the currently playing message ID or null when stopped
  Stream<String?> get currentlyPlayingMessageIdStream =>
      _player.playerStateStream.map((_) => _currentlyPlayingMessageId);

  /// Stream that emits player state changes
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Initialize the audio service
  void _init() {
    // Set up player behavior
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentlyPlayingMessageId = null;
      }
    });
  }

  /// Get voice context information for a message
  ///
  /// This calls the voice_context endpoint to get voice type and latest AI message
  Future<Map<String, dynamic>> _getVoiceContext(String messageId) async {
    int retryCount = 0;
    const int maxContextRetries = 2;
    const int initialTimeout = 10;

    while (retryCount <= maxContextRetries) {
      try {
        final endpoint =
            ApiConstants.voice_context.replaceFirst('{message_id}', messageId);
        final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

        debugPrint(
            "Fetching voice context from: $uri (attempt ${retryCount + 1})");

        // Increase timeout slightly with each retry
        final timeout = Duration(seconds: initialTimeout + (retryCount * 5));

        final stopwatch = Stopwatch()..start();
        final response = await http
            .get(
          uri,
          headers: ApiConstants.authHeaders,
        )
            .timeout(
          timeout,
          onTimeout: () {
            debugPrint(
                'Voice context request timed out after ${timeout.inSeconds} seconds');
            return http.Response('Connection timed out', 408);
          },
        );
        stopwatch.stop();

        debugPrint(
            'Voice context response received in ${stopwatch.elapsedMilliseconds}ms with status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data =
              Map<String, dynamic>.from(json.decode(response.body) as Map);
          debugPrint(
              'Voice context fetched successfully: ${data['voice_type']}');
          return data;
        } else if (response.statusCode == 408 ||
            response.statusCode == 503 ||
            response.statusCode == 504) {
          // Retry on timeout or service unavailable
          retryCount++;
          if (retryCount <= maxContextRetries) {
            final backoffDelay = retryDelay * (1 << retryCount);
            debugPrint(
                'Voice context request failed with ${response.statusCode}, retrying in ${backoffDelay}ms...');
            await Future.delayed(Duration(milliseconds: backoffDelay));
          } else {
            throw Exception(
                'Failed to get voice context after $maxContextRetries retries: ${response.statusCode}');
          }
        } else {
          throw Exception(
              'Failed to get voice context: ${response.statusCode}');
        }
      } catch (e) {
        if (e is Exception &&
            e.toString().contains('Failed to get voice context')) {
          rethrow; // This is already our formatted exception, so rethrow it
        }

        retryCount++;
        if (retryCount <= maxContextRetries) {
          final backoffDelay = retryDelay * (1 << retryCount);
          debugPrint('Error getting voice context: $e');
          debugPrint('Retrying in ${backoffDelay}ms...');
          await Future.delayed(Duration(milliseconds: backoffDelay));
        } else {
          debugPrint(
              'Failed to get voice context after $maxContextRetries retries: $e');
          rethrow;
        }
      }
    }

    // This should not be reached due to the retry logic above, but adding as a fallback
    throw Exception('Failed to get voice context after exhausting retries');
  }

  /// Play audio for a specific message
  ///
  /// [messageId] - ID of the message to play
  /// [autoPlay] - Whether to play automatically after loading
  /// [isFirstAppearance] - Whether this is the first time the message appears
  Future<void> playMessageAudio(String messageId,
      {bool autoPlay = true, bool isFirstAppearance = false}) async {
    // If this is auto-play and we've already played this message, skip it
    if (autoPlay &&
        isFirstAppearance &&
        _autoPlayedMessages.contains(messageId)) {
      return;
    }

    // Stop current playback if there is any
    if (_player.playing) {
      await _player.stop();
    }
    _currentlyPlayingMessageId = messageId;

    try {
      // Check if the audio is already cached
      if (_cachedFiles.containsKey(messageId)) {
        debugPrint('Playing cached audio for message $messageId');
        await _player.setFilePath(_cachedFiles[messageId]!);
      } else {
        debugPrint('Streaming audio for message $messageId');
        await _streamAndCacheAudio(messageId);
      }

      if (autoPlay) {
        await _player.play();
        if (isFirstAppearance) {
          _autoPlayedMessages.add(messageId);
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _currentlyPlayingMessageId = null;
      if (e.toString().contains('503') || e.toString().contains('504')) {
        throw Exception(
            'AI voice is temporarily unavailable. Please try again later.');
      }
      rethrow;
    }
  }

  /// Stream audio from the server and cache it locally
  Future<void> _streamAndCacheAudio(String messageId) async {
    // First, get the voice context information for this message
    Map<String, dynamic> voiceContext;
    String voiceType = 'hm_omega'; // Default voice type
    Map<String, dynamic>? latestAiMessage;
    String messageContent = '';
    bool isLatestMessage = false;

    try {
      // Fetch voice context with error handling
      voiceContext = await _getVoiceContext(messageId);
      voiceType = voiceContext['voice_type'] ?? 'hm_omega';

      // Get latest AI message content
      latestAiMessage =
          voiceContext['latest_ai_message'] as Map<String, dynamic>?;

      if (latestAiMessage != null) {
        messageContent = latestAiMessage['content'] ?? '';
        isLatestMessage = latestAiMessage['id'] == messageId;

        if (messageContent.isNotEmpty) {
          debugPrint(
              'Found message content (${messageContent.length} chars): ${messageContent.substring(0, messageContent.length > 30 ? 30 : messageContent.length)}...');
        }
      }
    } catch (e) {
      debugPrint('Warning: Failed to get voice context: $e');
      // Continue with defaults if voice context fails
    }

    debugPrint('Using voice type: $voiceType');

    int retryCount = 0;
    Exception? lastError;
    bool directTtsAttempted = false;

    while (retryCount < maxRetries) {
      try {
        // First attempt: If this is latest message with content, try streaming audio chunks directly
        if (!directTtsAttempted &&
            messageContent.isNotEmpty &&
            isLatestMessage) {
          debugPrint(
              'Attempting to stream audio chunks directly with latest message content');
          try {
            // Use streaming method instead of the regular direct call
            await _streamAudioChunksFromTts(
                messageContent, voiceType, messageId);
            return; // Success, exit the retry loop
          } catch (e) {
            debugPrint('Streaming audio chunks failed: $e');
            directTtsAttempted = true;
            // If streaming fails, try the regular direct call
            try {
              debugPrint('Falling back to regular direct TTS call');
              await _callTtsServiceDirectly(
                  messageContent, voiceType, messageId);
              return; // Success, exit the retry loop
            } catch (e) {
              debugPrint('Direct TTS call also failed: $e');
              // Don't increment retry count, fall through to backend method
            }
          }
        }

        // Second attempt or fallback: Use the backend endpoint
        final endpoint =
            ApiConstants.speechEndpoint.replaceFirst('{message_id}', messageId);
        final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
        debugPrint("Streaming audio from backend at: $uri");

        final stopwatch = Stopwatch()..start();
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${ApiConstants.token}',
            'Accept': 'audio/mpeg',
          },
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('Backend request timed out after 30 seconds');
            return http.Response('Connection timed out', 504);
          },
        );
        stopwatch.stop();

        debugPrint(
            'Backend responded in ${stopwatch.elapsedMilliseconds}ms with status: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint(
              'Successfully received audio from backend (${response.bodyBytes.length} bytes)');

          // Save to cache
          final cacheFile =
              await _saveToCacheFile(messageId, response.bodyBytes);
          _cachedFiles[messageId] = cacheFile.path;

          // Set the audio source for the player
          await _player.setFilePath(cacheFile.path);
          return; // Success, exit the retry loop
        } else if (response.statusCode == 503 || response.statusCode == 504) {
          throw Exception(
              'Text-to-speech service is temporarily unavailable (${response.statusCode})');
        } else {
          throw Exception('Failed to load audio: ${response.statusCode}');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retryCount++;

        if (retryCount < maxRetries) {
          // Implement exponential backoff with jitter for better retry distribution
          final backoffDelay =
              retryDelay * (1 << retryCount); // 500ms, 1s, 2s, etc.
          debugPrint('Retry attempt $retryCount after error: $e');
          debugPrint('Waiting ${backoffDelay}ms before retrying...');
          await Future.delayed(Duration(milliseconds: backoffDelay));
        }
      }
    }

    throw lastError ??
        Exception('Failed to stream audio after $maxRetries attempts');
  }

  /// Call the TTS service directly without going through the backend
  ///
  /// This prepares a payload similar to the Python backend's get_speech_from_tts_service
  Future<void> _callTtsServiceDirectly(
      String textToSpeak, String voiceName, String messageId) async {
    final ttsEndpoint = '${ApiConstants.ttsBaseUrl}/v1/audio/speech';
    final uri = Uri.parse(ttsEndpoint);

    debugPrint('Calling TTS service directly at: $uri with voice: $voiceName');

    // Prepare payload exactly matching the Python backend implementation
    final payload = {
      'model': 'kokoro', // Default TTS model
      'input': textToSpeak,
      'voice': voiceName,
      'response_format': 'mp3',
      'download_format': 'mp3',
      'speed': 1.3, // Matching the speed used in backend
      'stream': false, // We can't handle streaming directly in Flutter HTTP
      'return_download_link': false,
      'lang_code': 'en-US',
      'normalization_options': {
        'normalize': true,
        'unit_normalization': false,
        'url_normalization': true,
        'email_normalization': true,
        'optional_pluralization_normalization': true,
        'phone_normalization': true
      }
    };

    // Match headers exactly to what the backend uses
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'audio/mpeg',
    };

    int retryCount = 0;
    Exception? lastError;

    while (retryCount < maxRetries) {
      try {
        debugPrint('Attempt ${retryCount + 1} to call TTS service directly');

        // Make POST request to TTS service
        final stopwatch = Stopwatch()..start();
        final response = await http
            .post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        )
            .timeout(
          const Duration(seconds: 45), // Longer timeout for TTS generation
          onTimeout: () {
            debugPrint('TTS service request timed out after 45 seconds');
            return http.Response(
                'Connection timed out', 504); // Gateway Timeout
          },
        );
        stopwatch.stop();

        debugPrint(
            'TTS service responded in ${stopwatch.elapsedMilliseconds}ms with status: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint(
              'Successfully received audio from TTS service (${response.bodyBytes.length} bytes)');

          // Save to cache
          final cacheFile =
              await _saveToCacheFile(messageId, response.bodyBytes);
          _cachedFiles[messageId] = cacheFile.path;

          debugPrint('Audio cached at: ${cacheFile.path}');

          // Set the audio source for the player
          await _player.setFilePath(cacheFile.path);
          return; // Success
        } else {
          // Try to get error details
          String errorBody = 'No response body';
          try {
            if (response.body.isNotEmpty) {
              errorBody = response.body.substring(
                  0, response.body.length > 100 ? 100 : response.body.length);
            }
          } catch (e) {
            errorBody = 'Could not extract error body: $e';
          }

          debugPrint(
              'TTS service returned error status: ${response.statusCode}');
          debugPrint('Error response: $errorBody');

          // Handle specific error codes
          if (response.statusCode == 503 || response.statusCode == 504) {
            throw Exception('TTS service temporarily unavailable');
          } else {
            throw Exception('TTS service error: ${response.statusCode}');
          }
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retryCount++;

        if (retryCount < maxRetries) {
          // Implement exponential backoff
          final backoffDelay =
              retryDelay * (1 << retryCount); // 500ms, 1s, 2s, etc.
          debugPrint(
              'Retry attempt $retryCount for direct TTS call after error: $e');
          debugPrint('Waiting ${backoffDelay}ms before retrying...');
          await Future.delayed(Duration(milliseconds: backoffDelay));
        }
      }
    }

    throw lastError ??
        Exception(
            'Failed to generate speech directly after $maxRetries attempts');
  }

  /// Stream audio chunks directly from the TTS service and play them as they arrive
  ///
  /// This method allows for faster playback start by streaming audio in chunks instead of
  /// waiting for the entire file to download first.
  Future<void> _streamAudioChunksFromTts(
      String textToSpeak, String voiceName, String messageId) async {
    final ttsEndpoint = '${ApiConstants.ttsBaseUrl}/v1/audio/speech';
    final uri = Uri.parse(ttsEndpoint);

    debugPrint(
        'Streaming audio chunks from TTS service at: $uri with voice: $voiceName');

    // Prepare payload similar to the backend, but with stream=true
    final payload = {
      'model': 'kokoro',
      'input': textToSpeak,
      'voice': voiceName,
      'response_format': 'mp3',
      'download_format': 'mp3',
      'speed': 1,
      'stream': true, // Enable streaming from TTS service
      'return_download_link': false,
      'lang_code': 'en-US',
      'normalization_options': {
        'normalize': true,
        'unit_normalization': false,
        'url_normalization': true,
        'email_normalization': true,
        'optional_pluralization_normalization': true,
        'phone_normalization': true
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'audio/mpeg',
    };

    // Create a temporary file for streaming
    final cacheDir = await getTemporaryDirectory();
    final cacheFile =
        File('${cacheDir.path}/ai_message_${messageId}_stream.mp3');

    // Make sure we start with a fresh file
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
    await cacheFile.create();

    // Get file sink for writing chunks
    final fileSink = cacheFile.openWrite();

    // Create a client for streaming
    final client = http.Client();
    bool hasStartedPlaying = false;
    bool hasError = false;
    int bytesReceived = 0;
    const initialBufferSize = 12288;

    try {
      // Create the request
      final request = http.Request('POST', uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(payload);

      // Send the request and get the stream
      debugPrint('Sending streaming request to TTS service...');
      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception('TTS streaming request timed out after 45 seconds');
        },
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'TTS service returned error code: ${streamedResponse.statusCode}');
      }

      debugPrint(
          'TTS service streaming response received, processing chunks...');

      // Process the stream
      streamedResponse.stream.listen(
        (List<int> chunk) async {
          // Write chunk to file
          fileSink.add(chunk);
          bytesReceived += chunk.length;

          debugPrint(
              'Received chunk: ${chunk.length} bytes, total: $bytesReceived bytes');

          // Start playback once we have enough initial data
          if (!hasStartedPlaying && bytesReceived >= initialBufferSize) {
            debugPrint(
                'Starting playback with initial buffer of $bytesReceived bytes');
            hasStartedPlaying = true;

            // Add to cache map for future playback
            _cachedFiles[messageId] = cacheFile.path;

            // We need to flush the data to the file so it's available for playback
            await fileSink.flush();

            try {
              // Start playback on the main thread to avoid UI blocking
              await Future.microtask(() async {
                // Set the audio source for the player
                debugPrint(
                    'Setting file path for streaming playback: ${cacheFile.path}');
                await _player.setFilePath(cacheFile.path);
                debugPrint('Starting audio playback while streaming continues');
                await _player.play();
              });
            } catch (e) {
              debugPrint('Error starting playback during streaming: $e');
              hasStartedPlaying = false; // Allow retry on next chunk
            }
          }
        },
        onDone: () async {
          debugPrint(
              'TTS streaming completed, received total of $bytesReceived bytes');
          try {
            await fileSink.flush();
            await fileSink.close();

            // If we never started playing (very short audio), start now
            if (!hasStartedPlaying && !hasError) {
              _cachedFiles[messageId] = cacheFile.path;
              await _player.setFilePath(cacheFile.path);
              await _player.play();
            }
          } catch (e) {
            debugPrint('Error finalizing audio file: $e');
          }
        },
        onError: (e) async {
          hasError = true;
          debugPrint('Error during TTS streaming: $e');
          try {
            await fileSink.close();
          } catch (_) {}
        },
        cancelOnError: true,
      );
    } catch (e) {
      hasError = true;
      debugPrint('Error in TTS streaming: $e');
      try {
        await fileSink.close();
      } catch (_) {}
      client.close();
      rethrow;
    }
  }

  /// Save audio data to a cache file
  Future<File> _saveToCacheFile(String messageId, List<int> bytes) async {
    final cacheDir = await getTemporaryDirectory();
    final cacheFile = File('${cacheDir.path}/ai_message_$messageId.mp3');
    return await cacheFile.writeAsBytes(bytes);
  }

  /// Stop playback if playing
  Future<void> stop() async {
    if (_player.playing) {
      await _player.stop();
      _currentlyPlayingMessageId = null;
    }
  }

  /// Check if a message's audio is currently playing
  bool isPlaying(String messageId) {
    return _currentlyPlayingMessageId == messageId && _player.playing;
  }

  /// Pause playback
  Future<void> pause() async {
    if (_player.playing) {
      await _player.pause();
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (!_player.playing && _currentlyPlayingMessageId != null) {
      await _player.play();
    }
  }

  /// Clean up old cache files
  Future<void> cleanupCache({int keepLatest = 20}) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final files = cacheDir
          .listSync()
          .where((entity) =>
              entity is File &&
              entity.path.contains('ai_message_') &&
              entity.path.endsWith('.mp3'))
          .toList();

      // If we have more cached files than we want to keep
      if (files.length > keepLatest) {
        // Sort by modification time (newest first)
        files.sort((a, b) => File(b.path)
            .lastModifiedSync()
            .compareTo(File(a.path).lastModifiedSync()));

        // Delete older files
        for (int i = keepLatest; i < files.length; i++) {
          final file = File(files[i].path);
          await file.delete();

          // Remove from cache map
          _cachedFiles.removeWhere((key, value) => value == file.path);
        }
      }
    } catch (e) {
      debugPrint('Error cleaning cache: $e');
    }
  }

  /// Dispose the player when no longer needed
  void dispose() {
    _player.dispose();
  }
}

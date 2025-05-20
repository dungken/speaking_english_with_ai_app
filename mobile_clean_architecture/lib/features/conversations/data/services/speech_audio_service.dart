import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
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

  /// Base URL for the API - should be configured from env or config
  String _baseUrl = ApiConstants.baseUrl;

  /// Current playing message ID, if any
  String? _currentlyPlayingMessageId;

  /// Maximum number of retry attempts for streaming audio
  static const int maxRetries = 3;

  /// Delay between retries in milliseconds
  static const int retryDelay = 1000;

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

  /// Configure the base URL for the API
  void configureBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
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
      if (e.toString().contains('503')) {
        throw Exception(
            'AI voice is temporarily unavailable. Please try again later.');
      }
      rethrow;
    }
  }

  /// Stream audio from the server and cache it locally
  Future<void> _streamAndCacheAudio(String messageId) async {
    final endpoint =
        ApiConstants.speechEndpoint.replaceFirst('{message_id}', messageId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    debugPrint("uri: $uri");

    int retryCount = 0;
    Exception? lastError;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${ApiConstants.token}',
            'Accept': 'audio/mpeg',
          },
        );

        if (response.statusCode == 200) {
          // Save to cache
          final cacheFile =
              await _saveToCacheFile(messageId, response.bodyBytes);
          _cachedFiles[messageId] = cacheFile.path;

          // Set the audio source for the player
          await _player.setFilePath(cacheFile.path);
          return; // Success, exit the retry loop
        } else if (response.statusCode == 503) {
          throw Exception('Text-to-speech service is temporarily unavailable');
        } else {
          throw Exception('Failed to load audio: ${response.statusCode}');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retryCount++;

        if (retryCount < maxRetries) {
          debugPrint('Retry attempt $retryCount after error: $e');
          await Future.delayed(Duration(milliseconds: retryDelay));
        }
      }
    }

    throw lastError ??
        Exception('Failed to stream audio after $maxRetries attempts');
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

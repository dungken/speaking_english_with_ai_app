import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/audio_services.dart';
import '../../../../core/usecase/usecase.dart';

/// Parameters for [UploadAudioUseCase]
class UploadAudioParams {
  final String audioFilePath;

  UploadAudioParams({required this.audioFilePath});
}

/// Response from [UploadAudioUseCase]
class AudioUploadResponse {
  final String audioId;
  final String transcription;
  final bool success;

  AudioUploadResponse({
    required this.audioId,
    required this.transcription,
    this.success = true,
  });
}

/// Usecase for uploading an audio file and getting transcription
class UploadAudioUseCase
    implements UseCase<AudioUploadResponse, UploadAudioParams> {
  final AudioService audioService;

  UploadAudioUseCase({required this.audioService});

  @override
  Future<Either<Failure, AudioUploadResponse>> call(
      UploadAudioParams params) async {
    try {
      final result = await audioService.uploadAudioAndGetTranscription(
        params.audioFilePath,
      );

      return Right(
        AudioUploadResponse(
          audioId: result['audio_id'] ?? '',
          transcription: result['transcription'] ?? '',
          success: result['success'] ?? true,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to upload audio: $e',
        ),
      );
    }
  }
}

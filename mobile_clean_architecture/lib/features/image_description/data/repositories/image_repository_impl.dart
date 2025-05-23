import 'package:dartz/dartz.dart';
import 'package:mobile_clean_architecture/core/error/exceptions.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/network/network_info.dart';
import 'package:mobile_clean_architecture/features/image_description/data/datasources/image_remote_data_source.dart';
import 'package:mobile_clean_architecture/features/image_description/data/models/feedback_request.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/repositories/image_repository.dart';

/// Implementation of the ImageRepository interface
class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  /// Creates an ImageRepositoryImpl instance
  const ImageRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ImageEntity>>> getPracticeImages() async {
    if (await networkInfo.isConnected) {
      try {
        final images = await remoteDataSource.getPracticeImages();
        return Right(images);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> getImageUrl(String imageId) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.getImageUrl(imageId);
        return Right(imageUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ImageFeedbackEntity>> getImageFeedback({
    required String userId,
    required String imageId,
    required String userTranscription,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = ImageFeedbackRequest(
          userId: userId,
          imageId: imageId,
          userTranscription: userTranscription,
        );

        final feedback = await remoteDataSource.getImageFeedback(request);
        return Right(feedback);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}

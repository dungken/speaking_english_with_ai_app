import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/usecases/usecase.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/repositories/image_repository.dart';

/// UseCase for getting image URL by ID
class GetImageUrl extends UseCase<String, ImageParams> {
  final ImageRepository repository;

  /// Creates a GetImageUrl use case
  GetImageUrl(this.repository);

  @override
  Future<Either<Failure, String>> call(ImageParams params) {
    return repository.getImageUrl(params.imageId);
  }
}

/// Parameters for GetImageUrl use case
class ImageParams extends Equatable {
  /// ID of the image
  final String imageId;

  /// Creates ImageParams instance
  const ImageParams({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

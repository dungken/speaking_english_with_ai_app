import 'package:dartz/dartz.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/usecases/usecase.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/repositories/image_repository.dart';

/// UseCase for getting practice images
class GetPracticeImages extends UseCase<List<ImageEntity>, NoParams> {
  final ImageRepository repository;

  /// Creates a GetPracticeImages use case
  GetPracticeImages(this.repository);

  @override
  Future<Either<Failure, List<ImageEntity>>> call(NoParams params) {
    return repository.getPracticeImages();
  }
}

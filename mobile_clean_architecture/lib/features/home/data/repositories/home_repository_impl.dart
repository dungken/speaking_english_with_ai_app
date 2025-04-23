import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_type.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Either<Failure, List<HomeType>>> getHomeTypes() async {
    try {
      // In a real app, this would come from an API or local storage
      return Right(HomeType.values.toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    try {
      // In a real app, this would come from an API or local storage
      return const Right({
        'name': 'Demo User',
        'email': 'demo@example.com',
        'avatar': null,
      });
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      // In a real app, this would update an API or local storage
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

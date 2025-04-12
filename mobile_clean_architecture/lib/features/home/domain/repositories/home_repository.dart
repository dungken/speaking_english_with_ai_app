import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_type.dart';

abstract class HomeRepository {
  /// Get all available home types
  Future<Either<Failure, List<HomeType>>> getHomeTypes();

  /// Get user profile data
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile();

  /// Update user profile
  Future<Either<Failure, void>> updateUserProfile(
      Map<String, dynamic> profileData);
}

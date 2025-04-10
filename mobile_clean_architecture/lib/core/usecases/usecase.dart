import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Interface for all UseCases in the application
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase with no parameters
class NoParams {}

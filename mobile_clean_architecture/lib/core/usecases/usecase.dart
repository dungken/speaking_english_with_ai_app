import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Interface for all UseCases in the application
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Class for use cases that don't require parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

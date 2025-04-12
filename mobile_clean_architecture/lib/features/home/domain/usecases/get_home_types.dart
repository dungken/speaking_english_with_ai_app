import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/home_type.dart';
import '../repositories/home_repository.dart';

class GetHomeTypes implements UseCase<List<HomeType>, NoParams> {
  final HomeRepository repository;

  GetHomeTypes(this.repository);

  @override
  Future<Either<Failure, List<HomeType>>> call(NoParams params) async {
    return await repository.getHomeTypes();
  }
}

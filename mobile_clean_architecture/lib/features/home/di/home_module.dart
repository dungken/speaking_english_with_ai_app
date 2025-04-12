import 'package:get_it/get_it.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_types.dart';
import '../presentation/cubit/home_cubit.dart';

void initHomeModule() {
  final getIt = GetIt.instance;

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetHomeTypes(getIt()),
  );

  // Cubits
  getIt.registerFactory(
    () => HomeCubit(
      getHomeTypes: getIt(),
    ),
  );
}

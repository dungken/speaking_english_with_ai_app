import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../data/models/user_model.dart';
import '../presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void initAuthModule() {
  // Register BLoC
  sl.registerFactory(
    () => AuthBloc(),
  );
}

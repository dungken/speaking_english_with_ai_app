import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/home_type.dart';
import '../../domain/usecases/get_home_types.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeTypes getHomeTypes;

  HomeCubit({required this.getHomeTypes}) : super(const HomeState.initial());

  Future<void> loadHomeTypes() async {
    emit(const HomeState.loading());
    try {
      final result = await getHomeTypes(const NoParams());
      result.fold(
        (failure) => emit(HomeState.error(failure.message ?? 'Unknown error')),
        (homeTypes) => emit(HomeState.loaded(homeTypes)),
      );
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }
}

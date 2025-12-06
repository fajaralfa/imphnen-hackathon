import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/decrement_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/get_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/increment_counter.dart';

part 'counter_state.dart';

/// Cubit for managing Counter state following Clean Architecture.
///
/// The Cubit depends on Use Cases (not repositories) which encapsulate
/// the business logic. This keeps the presentation layer thin and
/// focused only on state management.
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
    required this.decrementCounter,
  }) : super(const CounterInitial());

  final GetCounter getCounter;
  final IncrementCounter incrementCounter;
  final DecrementCounter decrementCounter;

  /// Loads the current counter value.
  Future<void> loadCounter() async {
    emit(const CounterLoading());

    final result = await getCounter(const NoParams());

    result.fold(
      (failure) => emit(const CounterError('Failed to load counter')),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  /// Increments the counter value.
  Future<void> increment() async {
    final result = await incrementCounter(const NoParams());

    result.fold(
      (failure) => emit(const CounterError('Failed to increment counter')),
      (counter) => emit(CounterLoaded(counter)),
    );
  }

  /// Decrements the counter value.
  Future<void> decrement() async {
    final result = await decrementCounter(const NoParams());

    result.fold(
      (failure) => emit(const CounterError('Failed to decrement counter')),
      (counter) => emit(CounterLoaded(counter)),
    );
  }
}

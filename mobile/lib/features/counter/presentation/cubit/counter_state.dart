part of 'counter_cubit.dart';

/// Represents all possible states for the Counter feature.
///
/// Using sealed classes allows for exhaustive pattern matching
/// and makes state handling explicit and type-safe.
sealed class CounterState extends Equatable {
  const CounterState();
}

/// Initial state when the counter hasn't been loaded yet.
final class CounterInitial extends CounterState {
  const CounterInitial();

  @override
  List<Object?> get props => [];
}

/// State while the counter is being loaded or updated.
final class CounterLoading extends CounterState {
  const CounterLoading();

  @override
  List<Object?> get props => [];
}

/// State when the counter value has been successfully loaded.
final class CounterLoaded extends CounterState {
  const CounterLoaded(this.counter);

  final CounterEntity counter;

  /// Convenience getter for the counter value.
  int get value => counter.value;

  @override
  List<Object?> get props => [counter];
}

/// State when an error occurred while loading/updating the counter.
final class CounterError extends CounterState {
  const CounterError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

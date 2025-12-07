import 'package:equatable/equatable.dart';

/// Counter entity representing the core business object.
///
/// In Clean Architecture, entities are the innermost layer and
/// contain enterprise-wide business rules. They are the least
/// likely to change when something external changes.
class CounterEntity extends Equatable {
  const CounterEntity({required this.value});

  /// Creates a CounterEntity with an initial value of 0.
  const CounterEntity.initial() : value = 0;

  /// The current counter value.
  final int value;

  /// Returns a new CounterEntity with the value incremented by 1.
  CounterEntity increment() => CounterEntity(value: value + 1);

  /// Returns a new CounterEntity with the value decremented by 1.
  CounterEntity decrement() => CounterEntity(value: value - 1);

  @override
  List<Object?> get props => [value];
}

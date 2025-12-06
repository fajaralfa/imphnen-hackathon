import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';

/// Data model for Counter that extends the domain entity.
///
/// Models in the data layer are responsible for:
/// - Serialization/deserialization (toJson/fromJson)
/// - Converting between external data formats and domain entities
///
/// For this simple counter example, the model mirrors the entity,
/// but in real apps, models often have additional fields for
/// API-specific data or database IDs.
class CounterModel extends CounterEntity {
  const CounterModel({required super.value});

  /// Creates a CounterModel from a JSON map.
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(value: json['value'] as int);
  }

  /// Creates a CounterModel from a domain entity.
  factory CounterModel.fromEntity(CounterEntity entity) {
    return CounterModel(value: entity.value);
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {'value': value};
  }

  /// Converts the model back to a domain entity.
  CounterEntity toEntity() {
    return CounterEntity(value: value);
  }
}

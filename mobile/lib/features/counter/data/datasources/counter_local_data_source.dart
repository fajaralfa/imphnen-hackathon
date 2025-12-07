import 'package:imphenhackaton/features/counter/data/models/counter_model.dart';

/// Abstract interface for local counter data operations.
///
/// Data sources are responsible for fetching data from a specific source
/// (local storage, remote API, etc.). This abstraction allows us to
/// easily swap implementations (e.g., SharedPreferences, Hive, SQLite).
abstract class CounterLocalDataSource {
  /// Gets the cached counter value.
  Future<CounterModel> getCounter();

  /// Caches the current counter value.
  Future<void> cacheCounter(CounterModel counter);

  /// Increments and returns the new counter value.
  Future<CounterModel> incrementCounter();

  /// Decrements and returns the new counter value.
  Future<CounterModel> decrementCounter();
}

/// In-memory implementation of [CounterLocalDataSource].
///
/// This is a simple implementation that stores the counter in memory.
/// For persistence, you could replace this with SharedPreferences, Hive, etc.
class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  CounterLocalDataSourceImpl();

  /// In-memory cache of the counter value.
  CounterModel _cachedCounter = const CounterModel(value: 0);

  @override
  Future<CounterModel> getCounter() async {
    // Simulate async operation (like reading from disk)
    return _cachedCounter;
  }

  @override
  Future<void> cacheCounter(CounterModel counter) async {
    // Simulate async operation (like writing to disk)
    _cachedCounter = counter;
  }

  @override
  Future<CounterModel> incrementCounter() async {
    final newValue = _cachedCounter.value + 1;
    _cachedCounter = CounterModel(value: newValue);
    return _cachedCounter;
  }

  @override
  Future<CounterModel> decrementCounter() async {
    final newValue = _cachedCounter.value - 1;
    _cachedCounter = CounterModel(value: newValue);
    return _cachedCounter;
  }
}

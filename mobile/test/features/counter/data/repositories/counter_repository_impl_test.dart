import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imphenhackaton/features/counter/data/datasources/counter_local_data_source.dart';
import 'package:imphenhackaton/features/counter/data/models/counter_model.dart';
import 'package:imphenhackaton/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterLocalDataSource extends Mock
    implements CounterLocalDataSource {}

void main() {
  late CounterRepositoryImpl repository;
  late MockCounterLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCounterLocalDataSource();
    repository = CounterRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const tCounterModel = CounterModel(value: 5);
  const tCounterEntity = CounterEntity(value: 5);

  group('getCounter', () {
    test('should return counter entity when data source succeeds', () async {
      // arrange
      when(() => mockLocalDataSource.getCounter())
          .thenAnswer((_) async => tCounterModel);

      // act
      final result = await repository.getCounter();

      // assert
      expect(result, const Right<dynamic, CounterEntity>(tCounterEntity));
      verify(() => mockLocalDataSource.getCounter()).called(1);
    });
  });

  group('incrementCounter', () {
    const tIncrementedModel = CounterModel(value: 6);
    const tIncrementedEntity = CounterEntity(value: 6);

    test(
      'should return incremented counter entity when data source succeeds',
      () async {
        // arrange
        when(() => mockLocalDataSource.incrementCounter())
            .thenAnswer((_) async => tIncrementedModel);

        // act
        final result = await repository.incrementCounter();

        // assert
        expect(result, const Right<dynamic, CounterEntity>(tIncrementedEntity));
        verify(() => mockLocalDataSource.incrementCounter()).called(1);
      },
    );
  });

  group('decrementCounter', () {
    const tDecrementedModel = CounterModel(value: 4);
    const tDecrementedEntity = CounterEntity(value: 4);

    test(
      'should return decremented counter entity when data source succeeds',
      () async {
        // arrange
        when(() => mockLocalDataSource.decrementCounter())
            .thenAnswer((_) async => tDecrementedModel);

        // act
        final result = await repository.decrementCounter();

        // assert
        expect(result, const Right<dynamic, CounterEntity>(tDecrementedEntity));
        verify(() => mockLocalDataSource.decrementCounter()).called(1);
      },
    );
  });
}

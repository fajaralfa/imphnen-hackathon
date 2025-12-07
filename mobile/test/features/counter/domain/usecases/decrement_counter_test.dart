import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/decrement_counter.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late DecrementCounter useCase;
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
    useCase = DecrementCounter(mockRepository);
  });

  const tCounter = CounterEntity(value: 4);

  test('should decrement counter via the repository', () async {
    // arrange
    when(() => mockRepository.decrementCounter())
        .thenAnswer((_) async => const Right(tCounter));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Right<dynamic, CounterEntity>(tCounter));
    verify(() => mockRepository.decrementCounter()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

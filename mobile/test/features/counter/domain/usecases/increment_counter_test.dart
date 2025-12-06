import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/increment_counter.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late IncrementCounter useCase;
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
    useCase = IncrementCounter(mockRepository);
  });

  const tCounter = CounterEntity(value: 6);

  test('should increment counter via the repository', () async {
    // arrange
    when(() => mockRepository.incrementCounter())
        .thenAnswer((_) async => const Right(tCounter));

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, const Right<dynamic, CounterEntity>(tCounter));
    verify(() => mockRepository.incrementCounter()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

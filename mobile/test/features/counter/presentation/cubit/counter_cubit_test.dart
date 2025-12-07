import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/decrement_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/get_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/increment_counter.dart';
import 'package:imphenhackaton/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCounter extends Mock implements GetCounter {}

class MockIncrementCounter extends Mock implements IncrementCounter {}

class MockDecrementCounter extends Mock implements DecrementCounter {}

void main() {
  late CounterCubit cubit;
  late MockGetCounter mockGetCounter;
  late MockIncrementCounter mockIncrementCounter;
  late MockDecrementCounter mockDecrementCounter;

  setUp(() {
    mockGetCounter = MockGetCounter();
    mockIncrementCounter = MockIncrementCounter();
    mockDecrementCounter = MockDecrementCounter();
    cubit = CounterCubit(
      getCounter: mockGetCounter,
      incrementCounter: mockIncrementCounter,
      decrementCounter: mockDecrementCounter,
    );
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is CounterInitial', () {
    expect(cubit.state, isA<CounterInitial>());
  });

  group('loadCounter', () {
    const tCounter = CounterEntity(value: 5);

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoading, CounterLoaded] when getCounter succeeds',
      build: () {
        when(() => mockGetCounter(any()))
            .thenAnswer((_) async => const Right(tCounter));
        return cubit;
      },
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        isA<CounterLoading>(),
        isA<CounterLoaded>().having((s) => s.value, 'value', 5),
      ],
      verify: (_) {
        verify(() => mockGetCounter(const NoParams())).called(1);
      },
    );

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoading, CounterError] when getCounter fails',
      build: () {
        when(() => mockGetCounter(any()))
            .thenAnswer((_) async => const Left(CacheFailure()));
        return cubit;
      },
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        isA<CounterLoading>(),
        isA<CounterError>(),
      ],
    );
  });

  group('increment', () {
    const tIncrementedCounter = CounterEntity(value: 6);

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoaded] when incrementCounter succeeds',
      build: () {
        when(() => mockIncrementCounter(any()))
            .thenAnswer((_) async => const Right(tIncrementedCounter));
        return cubit;
      },
      act: (cubit) => cubit.increment(),
      expect: () => [
        isA<CounterLoaded>().having((s) => s.value, 'value', 6),
      ],
      verify: (_) {
        verify(() => mockIncrementCounter(const NoParams())).called(1);
      },
    );

    blocTest<CounterCubit, CounterState>(
      'emits [CounterError] when incrementCounter fails',
      build: () {
        when(() => mockIncrementCounter(any()))
            .thenAnswer((_) async => const Left(CacheFailure()));
        return cubit;
      },
      act: (cubit) => cubit.increment(),
      expect: () => [
        isA<CounterError>(),
      ],
    );
  });

  group('decrement', () {
    const tDecrementedCounter = CounterEntity(value: 4);

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoaded] when decrementCounter succeeds',
      build: () {
        when(() => mockDecrementCounter(any()))
            .thenAnswer((_) async => const Right(tDecrementedCounter));
        return cubit;
      },
      act: (cubit) => cubit.decrement(),
      expect: () => [
        isA<CounterLoaded>().having((s) => s.value, 'value', 4),
      ],
      verify: (_) {
        verify(() => mockDecrementCounter(const NoParams())).called(1);
      },
    );

    blocTest<CounterCubit, CounterState>(
      'emits [CounterError] when decrementCounter fails',
      build: () {
        when(() => mockDecrementCounter(any()))
            .thenAnswer((_) async => const Left(CacheFailure()));
        return cubit;
      },
      act: (cubit) => cubit.decrement(),
      expect: () => [
        isA<CounterError>(),
      ],
    );
  });
}

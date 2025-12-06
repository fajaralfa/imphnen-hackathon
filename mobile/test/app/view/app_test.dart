import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:imphenhackaton/app/app.dart';
import 'package:imphenhackaton/core/usecases/usecase.dart';
import 'package:imphenhackaton/features/counter/counter.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCounter extends Mock implements GetCounter {}

class MockIncrementCounter extends Mock implements IncrementCounter {}

class MockDecrementCounter extends Mock implements DecrementCounter {}

void main() {
  // Use the exact same GetIt instance
  final sl = GetIt.instance;

  group('App', () {
    late MockGetCounter mockGetCounter;
    late MockIncrementCounter mockIncrementCounter;
    late MockDecrementCounter mockDecrementCounter;

    setUpAll(() {
      registerFallbackValue(const NoParams());
    });

    setUp(() async {
      // Reset and allow reassignment
      await sl.reset();

      mockGetCounter = MockGetCounter();
      mockIncrementCounter = MockIncrementCounter();
      mockDecrementCounter = MockDecrementCounter();

      // Stub the mock methods
      when(() => mockGetCounter(any())).thenAnswer(
        (_) async => const Right(CounterEntity(value: 0)),
      );
      when(() => mockIncrementCounter(any())).thenAnswer(
        (_) async => const Right(CounterEntity(value: 1)),
      );
      when(() => mockDecrementCounter(any())).thenAnswer(
        (_) async => const Right(CounterEntity(value: -1)),
      );

      // Register CounterCubit with mocked dependencies
      sl.registerFactory<CounterCubit>(
        () => CounterCubit(
          getCounter: mockGetCounter,
          incrementCounter: mockIncrementCounter,
          decrementCounter: mockDecrementCounter,
        ),
      );
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imphenhackaton/features/counter/domain/entities/counter_entity.dart';
import 'package:imphenhackaton/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:imphenhackaton/features/counter/presentation/pages/counter_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

class MockCounterCubit extends MockCubit<CounterState>
    implements CounterCubit {}

void main() {
  group('CounterView', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = MockCounterCubit();
    });

    testWidgets('renders current count when state is CounterLoaded',
        (tester) async {
      const state = CounterLoaded(CounterEntity(value: 42));
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders 0 when state is CounterInitial', (tester) async {
      const state = CounterInitial();
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders loading indicator when state is CounterLoading',
        (tester) async {
      const state = CounterLoading();
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when state is CounterError',
        (tester) async {
      const state = CounterError('Test error');
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('calls increment when increment button is tapped',
        (tester) async {
      const state = CounterLoaded(CounterEntity(value: 0));
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);
      when(() => counterCubit.increment()).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      verify(() => counterCubit.increment()).called(1);
    });

    testWidgets('calls decrement when decrement button is tapped',
        (tester) async {
      const state = CounterLoaded(CounterEntity(value: 0));
      when(() => counterCubit.state).thenReturn(state);
      whenListen(counterCubit, Stream.value(state), initialState: state);
      when(() => counterCubit.decrement()).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: const CounterView(),
        ),
      );
      await tester.tap(find.byIcon(Icons.remove));
      verify(() => counterCubit.decrement()).called(1);
    });
  });
}

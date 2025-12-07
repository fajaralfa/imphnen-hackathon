import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imphenhackaton/core/di/injection_container.dart';
import 'package:imphenhackaton/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:imphenhackaton/l10n/l10n.dart';

/// The main page for the Counter feature.
///
/// This page is responsible for:
/// - Providing the Cubit to the widget tree (from the DI container)
/// - Triggering initial data loading
/// - Delegating UI rendering to child widgets
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CounterCubit>()..loadCounter(),
      child: const CounterView(),
    );
  }
}

/// The main view widget for displaying the counter UI.
///
/// Separated from [CounterPage] to make testing easier -
/// the page handles DI, the view handles UI.
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.counterAppBarTitle)),
      body: const Center(child: CounterText()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays the current counter value.
///
/// Uses BlocBuilder to rebuild only when the state changes.
/// Handles all possible states: initial, loading, loaded, and error.
class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        return switch (state) {
          CounterInitial() => Text(
              '0',
              style: theme.textTheme.displayLarge,
            ),
          CounterLoading() => const CircularProgressIndicator(),
          CounterLoaded(:final value) => Text(
              '$value',
              style: theme.textTheme.displayLarge,
            ),
          CounterError(:final message) => Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
            ),
        };
      },
    );
  }
}

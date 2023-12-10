import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

const k10ms = Duration(milliseconds: 10);

Future<String> counterFuture(int count) async {
  if (count > 3) {
    throw Exception('Count($count) too large');
  }

  await Future.delayed(Duration(milliseconds: count * 10));
  return '$count second has passed.';
}

class Counter extends StatelessWidget {
  const Counter({super.key, required this.counter});

  final WritableBeacon<int> counter;

  @override
  Widget build(BuildContext context) {
    counter.observe(context, (prev, next) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      if (next > prev && next > 3) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Count cannot be greater than 3'),
          ),
        );
      } else if (next < prev && next < 0) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Count cannot be negative'),
          ),
        );
      }
    });
    return Text(
      counter.watch(context).toString(),
      style: Theme.of(context).textTheme.headlineMedium!,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key, required this.derived});

  final FutureBeacon<String> derived;

  @override
  Widget build(BuildContext context) {
    return switch (derived.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      _ => const CircularProgressIndicator(),
    };
  }
}

void main() {
  testWidgets('should rebuild Counter widget when count changes',
      (WidgetTester tester) async {
    final counter = Beacon.writable(0);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Counter(counter: counter),
      ),
    ));

    expect(find.text('0'), findsOneWidget);

    counter.increment();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Counter(counter: counter),
      ),
    ));

    // Verify updated state
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('should rebuild FutureCounter on state changes',
      (WidgetTester tester) async {
    final counter = Beacon.writable(0);

    final derivedFutureCounter = Beacon.derivedFuture(() async {
      final count = counter.value;
      return await counterFuture(count);
    });

    await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureCounter(derived: derivedFutureCounter),
          ),
        ),
        k10ms);

    expect(find.text('${counter.value} second has passed.'), findsOneWidget);

    counter.increment();

    await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureCounter(derived: derivedFutureCounter),
          ),
        ),
        k10ms * 2);
    // Verify loading indicator
    expect(find.text('${counter.value} second has passed.'), findsOneWidget);

    counter.value = 5;

    await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureCounter(derived: derivedFutureCounter),
          ),
        ),
        k10ms * 2);

    expect(
      find.text('Exception: Count(${counter.value}) too large'),
      findsOneWidget,
    );
  });

  testWidgets('should show snackbar for exceeding 3',
      (WidgetTester tester) async {
    // Build the Counter widget
    final counter = Beacon.writable(0);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Counter(counter: counter),
      ),
    ));

    // Increase counter beyond limit
    counter.value = 4;
    await tester.pumpAndSettle();

    // Verify snackbar visibility
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Count cannot be greater than 3'), findsOneWidget);
  });

  testWidgets('should show snackbar for going negative',
      (WidgetTester tester) async {
    // Build the Counter widget
    final counter = Beacon.writable(0);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Counter(counter: counter),
      ),
    ));

    // Decrease counter below limit
    counter.value = -1;
    await tester.pumpAndSettle();

    // Verify snackbar visibility
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Count cannot be negative'), findsOneWidget);
  });
}

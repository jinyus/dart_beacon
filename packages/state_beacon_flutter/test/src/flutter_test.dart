// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon_flutter/state_beacon_flutter.dart';

import '../common.dart';

void main() {
  BeaconScheduler.useFlutterScheduler();
  testWidgets('should rebuild Counter widget when count changes',
      (WidgetTester tester) async {
    final counter = Beacon.writable(0);

    final widget = Counter(counter: counter);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);

    counter.increment();

    await tester.pumpAndSettle();

    // Verify updated state
    expect(find.text('1'), findsOneWidget);
    expect(widget.builtCount, 2);
  });

  testWidgets('should rebuild FutureCounter on state changes',
      (WidgetTester tester) async {
    BeaconScheduler.useCustomFpsScheduler(60);
    // BeaconObserver.instance = LoggingObserver();
    final counter = Beacon.writable(0, name: 'counter');

    final derivedFutureCounter = Beacon.future(
      () async {
        final count = counter.value;
        return counterFuture(count);
      },
      name: 'derived',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FutureCounter(derived: derivedFutureCounter),
        ),
      ),
      k10ms,
    );

    await tester.pumpAndSettle();

    expect(find.text('${counter.value} second has passed.'), findsOneWidget);

    counter.increment();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FutureCounter(derived: derivedFutureCounter),
        ),
      ),
      k10ms * 2,
    );

    await tester.pumpAndSettle();

    // Verify loading indicator
    expect(find.text('${counter.value} second has passed.'), findsOneWidget);

    counter.value = 5;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FutureCounter(derived: derivedFutureCounter),
        ),
      ),
      k10ms * 2,
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Exception: Count(${counter.value}) too large'),
      findsOneWidget,
    );
  });

  testWidgets('should show snackbar for exceeding 3',
      (WidgetTester tester) async {
    // Build the Counter widget
    final counter = Beacon.writable(0);
    final widget = Counter(counter: counter);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    // Increase counter beyond limit
    counter.value = 4;
    await tester.pumpAndSettle();

    // Verify snackbar visibility
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Count cannot be greater than 3'), findsOneWidget);
    expect(widget.observedCount, 1);
  });

  testWidgets('should batch calls observe ', (WidgetTester tester) async {
    final counter = Beacon.writable(0);
    final widget = Counter(counter: counter);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    counter.increment();
    counter.increment();
    counter.increment();

    await tester.pumpAndSettle();

    expect(widget.observedCount, 1);
  });

  testWidgets('should call observe synchronously', (WidgetTester tester) async {
    final counter = Beacon.writable(0);
    final widget = Counter(counter: counter, synchronous: true);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    counter.increment();
    counter.increment();
    counter.increment();

    await tester.pumpAndSettle();

    expect(widget.observedCount, 3);
  });

  testWidgets('should show snackbar for going negative',
      (WidgetTester tester) async {
    // Build the Counter widget
    final counter = Beacon.writable(0);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Counter(counter: counter),
        ),
      ),
    );

    // Decrease counter below limit
    counter.value = -1;
    await tester.pumpAndSettle();

    // Verify snackbar visibility
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Count cannot be negative'), findsOneWidget);
  });

  testWidgets('listenersCount decreases on widget dispose',
      (WidgetTester tester) async {
    // BeaconObserver.instance = LoggingObserver();
    final testCounter = Beacon.writable(0, name: 'testCounter');
    // BeaconScheduler.setScheduler(flutterScheduler);

    // Check initial listeners count
    expect(testCounter.listenersCount, 0);

    // Build the 5 Counter widget, each with 2 listeners
    // 1 for the text and 1 for the observer
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Counter(counter: testCounter),
            Counter(counter: testCounter),
            Counter(counter: testCounter),
            Counter(counter: testCounter),
            Counter(counter: testCounter),
          ],
        ),
      ),
    );

    // Check listeners count after widget is built
    expect(testCounter.listenersCount, 10);

    // Dispose the Counter widget by pumping a different widget
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    testCounter.value = 1;

    await tester.pumpAndSettle();

    // Check listeners count after widget is disposed
    expect(testCounter.listenersCount, 0);

    testCounter.dispose();
  });
}

Future<String> counterFuture(int count) async {
  if (count > 3) {
    throw Exception('Count($count) too large');
  }

  await Future<void>.delayed(Duration(milliseconds: count * 10));
  return '$count second has passed.';
}

class CounterColumn extends StatelessWidget {
  const CounterColumn({required this.counter, required this.show, super.key});

  final WritableBeacon<int> counter;
  final WritableBeacon<bool> show;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: show.watch(context)
          ? [
              Counter(counter: counter),
              Counter(counter: counter),
              Counter(counter: counter),
              Counter(counter: counter),
              Counter(counter: counter),
            ]
          : [Container()],
    );
  }
}

// ignore: must_be_immutable
class Counter extends StatelessWidget {
  Counter({required this.counter, super.key, this.synchronous = false});

  final bool synchronous;
  final WritableBeacon<int> counter;

  int builtCount = 0;
  int observedCount = 0;

  @override
  Widget build(BuildContext context) {
    builtCount++;
    counter.observe(
      context,
      (prev, next) {
        observedCount++;
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
      },
      synchronous: synchronous,
    );
    return Text(
      counter.watch(context).toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({required this.derived, super.key});

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

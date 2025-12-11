// ignore_for_file: lines_longer_than_80_chars, hash_and_equals, avoid_equals_and_hash_code_on_mutable_classes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon_flutter/state_beacon_flutter.dart';

void main() {
  BeaconScheduler.useFlutterScheduler();

  testWidgets(
    'watch with forced hashCode collision demonstrates bug',
    (WidgetTester tester) async {
      final counter = Beacon.writable(0);
      const collisionHash = 999999;

      await tester.pumpWidget(
        MaterialApp(
          home: _CollisionWidget(
            counter: counter,
            forcedHash: collisionHash,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Away')),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Away'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: _CollisionWidget(
            counter: counter,
            forcedHash: collisionHash,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);

      counter.value = 2;
      await tester.pumpAndSettle();

      expect(
        find.text('Count: 2'),
        findsOneWidget,
        reason: 'Widget should rebuild when beacon changes after re-navigation',
      );
    },
  );

  testWidgets(
    'context hashCode investigation',
    (WidgetTester tester) async {
      final counter = Beacon.writable(0);
      // ignore: unused_local_variable
      BuildContext? firstContext;
      // ignore: unused_local_variable
      BuildContext? secondContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              firstContext = context;
              final count = counter.watch(context);
              return Scaffold(body: Text('First: $count'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      counter.value = 1;
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Away')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              secondContext = context;
              final count = counter.watch(context);
              return Scaffold(body: Text('Second: $count'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // debugPrint(
      //   'First - hash: ${firstContext?.hashCode}, '
      //   'identity: ${identityHashCode(firstContext)}',
      // );
      // debugPrint(
      //   'Second - hash: ${secondContext?.hashCode}, '
      //   'identity: ${identityHashCode(secondContext)}',
      // );
      // debugPrint(
      //   'HashCodes equal: ${firstContext?.hashCode == secondContext?.hashCode}',
      // );

      counter.value = 2;
      await tester.pumpAndSettle();

      expect(find.text('Second: 2'), findsOneWidget);
    },
  );

  testWidgets(
    'watch should rebuild after simulated navigation (Element reuse)',
    (WidgetTester tester) async {
      final counter = Beacon.writable(0);

      await tester.pumpWidget(
        MaterialApp(
          home: _TestPage(counter: counter, key: const Key('page1')),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      counter.value = 1;
      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Different Page')),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Different Page'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: _TestPage(counter: counter, key: const Key('page2')),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Count: 1'), findsOneWidget);

      counter.value = 2;
      await tester.pumpAndSettle();

      expect(find.text('Count: 2'), findsOneWidget);
    },
  );

  testWidgets(
    'watch should handle rapid navigation back and forth',
    (WidgetTester tester) async {
      final counter = Beacon.writable(0);

      for (var i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: _TestPage(counter: counter, key: Key('page$i')),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Count: $i'), findsOneWidget);

        counter.value = i + 1;
        await tester.pumpAndSettle();
        expect(find.text('Count: ${i + 1}'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Text('Away')),
          ),
        );

        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(
        MaterialApp(
          home: _TestPage(counter: counter, key: const Key('final')),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Count: 5'), findsOneWidget);

      counter.value = 99;
      await tester.pumpAndSettle();

      expect(find.text('Count: 99'), findsOneWidget);
    },
  );

  testWidgets(
    'watch should work with hashCode collisions',
    (WidgetTester tester) async {
      final counter = Beacon.writable(0);

      await tester.pumpWidget(
        MaterialApp(
          home: _CollisionTestPage(counter: counter),
        ),
      );

      await tester.pumpAndSettle();

      counter.value = 1;
      await tester.pumpAndSettle();

      final text1Finder = find.text('Widget1: 1');
      final text2Finder = find.text('Widget2: 1');

      expect(text1Finder, findsOneWidget);
      expect(text2Finder, findsOneWidget);
    },
  );
}

class _CollisionWidget extends StatefulWidget {
  const _CollisionWidget({
    required this.counter,
    required this.forcedHash,
  });

  final WritableBeacon<int> counter;
  final int forcedHash;

  @override
  State<_CollisionWidget> createState() => _CollisionWidgetStateWithHash();

  @override
  StatefulElement createElement() => _CollisionElement(this);
}

class _CollisionElement extends StatefulElement {
  _CollisionElement(super.widget);

  @override
  int get hashCode => (widget as _CollisionWidget).forcedHash;
}

class _CollisionWidgetStateWithHash extends State<_CollisionWidget> {
  @override
  Widget build(BuildContext context) {
    final count = widget.counter.watch(context);
    return Scaffold(
      body: Center(
        child: Text('Count: $count'),
      ),
    );
  }
}

class _TestPage extends StatelessWidget {
  const _TestPage({required this.counter, super.key});

  final WritableBeacon<int> counter;

  @override
  Widget build(BuildContext context) {
    final count = counter.watch(context);
    return Scaffold(
      body: Center(
        child: Text('Count: $count'),
      ),
    );
  }
}

class _CollisionTestPage extends StatelessWidget {
  const _CollisionTestPage({required this.counter});

  final WritableBeacon<int> counter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _WidgetWithHashCode(counter: counter, id: 1),
          _WidgetWithHashCode(counter: counter, id: 2),
        ],
      ),
    );
  }
}

class _WidgetWithHashCode extends StatelessWidget {
  const _WidgetWithHashCode({
    required this.counter,
    required this.id,
  });

  final WritableBeacon<int> counter;
  final int id;

  @override
  Widget build(BuildContext context) {
    final count = counter.watch(context);
    return Text('Widget$id: $count');
  }
}

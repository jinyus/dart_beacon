// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/infinite_list/infinite_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:state_beacon/state_beacon.dart';

class MockInfiniteController extends Mock implements InfiniteController {}

void main() {
  final infiniteCtrl = MockInfiniteController();

  testWidgets('Infinite List Page Test', (WidgetTester tester) async {
    final parsedItems = Beacon.writable(<ListItem>[ItemLoading()]);
    final pageNum = Beacon.filtered(1);
    final rawItems = Beacon.future(
      () => Future.value(['item1', 'item2']),
    );

    when(() => infiniteCtrl.rawItems).thenReturn(rawItems);
    when(() => infiniteCtrl.parsedItems).thenReturn(parsedItems);
    when(() => infiniteCtrl.pageNum).thenReturn(pageNum);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<InfiniteController>(
            create: (_) => infiniteCtrl,
            child: const InfiniteListPage(),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final testItems = [
      'item1',
      'item2',
    ];

    parsedItems.value = testItems.map(ItemData.new).toList();

    await tester.pumpAndSettle();

    expect(find.text('item1'), findsOneWidget);

    expect(find.byType(ItemTile), findsExactly(2));

    parsedItems.value = [ItemError('error')];

    await tester.pumpAndSettle();

    expect(find.text('error'), findsOneWidget);

    expect(find.byType(ItemTile), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/effect_closure.dart';
import 'package:state_beacon/src/listeners.dart';

void main() {
  test('should mirror internal set', () {
    final lst = Listeners();
    final closure = EffectClosure(() {});

    lst.add(closure);

    expect(lst.items.toList(), lst.itemsSet.toList());

    lst.remove(closure);

    expect(lst.items.toList(), lst.itemsSet.toList());
  });

  test('should correctly format toString', () {
    final closure = EffectClosure(() {});
    expect(closure.toString(), startsWith('EffectClosure(id:'));
  });

  test('should have the same hasCode as id', () {
    final closure = EffectClosure(() {});
    expect(closure.hashCode, closure.id.hashCode);

    final closure2 = EffectClosure(() {}, customID: closure.id);

    expect(closure, closure2);
  });
}

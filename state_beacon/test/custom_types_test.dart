import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/src/effect_closure.dart';
import 'package:state_beacon/src/listeners.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('shoud correctly format toString', () {
    final exn1 = WrapTargetWrongTypeException();

    expect(exn1.toString(), 'WrapTargetWrongTypeException: ${exn1.message}');

    final exn2 = CircularDependencyException();

    expect(exn2.toString(), 'CircularDependencyException: ${exn2.message}');

    final exn3 = DerivedBeaconStartedTwiceException();

    expect(
        exn3.toString(), 'DerivedBeaconStartedTwiceException: ${exn3.message}');

    final exn4 = UninitializeLazyReadException();

    expect(exn4.toString(), 'UninitializeLazyReadException: ${exn4.message}');
  });

  test('should use toString from superclass', () {
    final lst = Listeners();
    final closure = EffectClosure(() {});
    lst.add(closure);
    expect(lst.toString(), startsWith('[EffectClosure(id:'));
  });

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

  test('should share the same hashCode with sister instances', () {
    var data = AsyncData(1);
    var data2 = AsyncData(1);

    expect(data.hashCode, data2.hashCode);

    var load = AsyncLoading();
    var load2 = AsyncLoading();

    expect(load, load2);
    expect(load.hashCode, load2.hashCode);

    var stack = StackTrace.current;
    var error = AsyncError('error', stack);
    var error2 = AsyncError('error', stack);

    expect(error, error2);
    expect(error.hashCode, error2.hashCode);

    var idle = AsyncIdle();
    var idle2 = AsyncIdle();

    expect(idle, idle2);
    expect(idle.hashCode, idle2.hashCode);
  });
}

import 'common.dart';

var _globalEffectID = 0;

// This wrapper makes Set lookups faster
class EffectClosure {
  final int id;
  final VoidCallback run;

  EffectClosure(this.run, {int? customID}) : id = customID ?? ++_globalEffectID;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EffectClosure && other.id == id;
  }

  @override
  String toString() => 'EffectClosure(id: $id)';
}

// Callback add: 277ms
// Effect add: 178ms
// Callback lookup: 46ms
// Effect lookup: 9ms
// Callback remove: 10ms
// Effect remove: 8ms

// Future<void> main() async {
//   final callback = () => print('Hello, world!');
//   final effect = EffectClosure(() => print('Hello, world!'));

//   final callbackSet = <VoidCallback>{};
//   final effectSet = <EffectClosure>{};

//   final count = 1000000;

//   final sw = Stopwatch()..start();

//   for (var i = 0; i < count; i++) {
//     if (i == 500) {
//       callbackSet.add(callback);
//     } else {
//       callbackSet.add(() => print('Hello, world!'));
//     }
//   }

//   print('Callback add: ${sw.elapsedMilliseconds}ms');

//   sw.reset();

//   for (var i = 0; i < count; i++) {
//     if (i == 500) {
//       effectSet.add(effect);
//     } else {
//       effectSet.add(EffectClosure(() => print('Hello, world!')));
//     }
//   }

//   print('Effect add: ${sw.elapsedMilliseconds}ms');

//   sw.reset();

//   for (var i = 0; i < count; i++) {
//     callbackSet.contains(callback);
//   }

//   print('Callback lookup: ${sw.elapsedMilliseconds}ms');

//   sw.reset();

//   for (var i = 0; i < count; i++) {
//     effectSet.contains(effect);
//   }

//   print('Effect lookup: ${sw.elapsedMilliseconds}ms');

//   sw.reset();

//   for (var i = 0; i < count; i++) {
//     callbackSet.remove(callback);
//   }

//   print('Callback remove: ${sw.elapsedMilliseconds}ms');

//   sw.reset();

//   for (var i = 0; i < count; i++) {
//     effectSet.remove(effect);
//   }

//   print('Effect remove: ${sw.elapsedMilliseconds}ms');
// }

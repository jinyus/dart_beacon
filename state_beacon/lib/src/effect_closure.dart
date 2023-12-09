import 'common.dart';

var _globalEffectID = 0;

// This wrapper makes Set lookups faster
class EffectClosure {
  final int id;
  final VoidCallback run;

  EffectClosure(this.run, {int? customID}) : id = customID ?? ++_globalEffectID;

  @override
  String toString() => 'EffectClosure(id: $id)';
}

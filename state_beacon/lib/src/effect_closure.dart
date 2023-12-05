var _globalEffectID = 0;

typedef VoidCallback = void Function();

// This wrapper makes Set lookups faster
class EffectClosure {
  final int id;
  final VoidCallback run;

  EffectClosure(this.run, {int? customID}) : id = customID ?? ++_globalEffectID;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) {
    return other is EffectClosure && other.id == id;
  }

  @override
  String toString() => 'EffectClosure(id: $id)';
}

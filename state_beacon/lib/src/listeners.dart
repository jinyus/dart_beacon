import 'effect_closure.dart';

class Listeners {
  final Set<EffectClosure> _set = {};
  late List<EffectClosure> _list;

  Listeners() {
    _updateList();
  }

  int get length => _set.length;

  void _updateList() {
    _list = _set.toList();
  }

  bool add(EffectClosure item) {
    bool added = _set.add(item);
    if (added) {
      _list.add(item);
    }
    return added;
  }

  bool remove(EffectClosure item) {
    bool removed = _set.remove(item);
    if (removed) {
      _updateList();
    }
    return removed;
  }

  bool contains(EffectClosure item) {
    return _set.contains(item);
  }

  List<EffectClosure> get items => _list;

  void clear() {
    _set.clear();
    _list.clear();
  }

  @override
  String toString() {
    return _list.toString();
  }
}

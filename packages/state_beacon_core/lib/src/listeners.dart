import 'dart:collection';

import 'effect_closure.dart';

class Listeners {
  final HashSet<EffectClosure> _set = HashSet<EffectClosure>();
  List<EffectClosure> _list = [];

  int get length => _set.length;

  bool add(EffectClosure item) {
    bool added = _set.add(item);
    if (added) {
      _list.add(item);
    }
    return added;
  }

  void addAll(Iterable<EffectClosure> items) {
    _set.addAll(items);
    _list.addAll(items);
  }

  bool remove(EffectClosure item) {
    bool removed = _set.remove(item);
    if (removed) {
      // prevent concurrent modification
      _list = _list.toList()..remove(item);
    }
    return removed;
  }

  bool contains(EffectClosure item) {
    return _set.contains(item);
  }

  List<EffectClosure> get items => _list;
  HashSet<EffectClosure> get itemsSet => _set;

  void clear() {
    _set.clear();
    _list.clear();
  }

  // coverage:ignore-start
  @override
  String toString() {
    return _list.toString();
  }
  // coverage:ignore-end
}

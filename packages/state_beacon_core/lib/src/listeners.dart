// ignore_for_file: public_member_api_docs

import 'dart:collection';

import 'package:state_beacon_core/src/common.dart';

import 'effect_closure.dart';

class Listeners {
  final HashSet<EffectClosure> _set = HashSet<EffectClosure>();
  List<EffectClosure> _list = [];

  late final _whenEmptyCallbacks = <VoidCallback>[];

  int get length => _set.length;

  bool add(EffectClosure item) {
    final added = _set.add(item);
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
    final removed = _set.remove(item);
    if (removed) {
      // prevent concurrent modification
      _list = _list.toList()..remove(item);

      if (_set.isEmpty) {
        for (final callback in _whenEmptyCallbacks) {
          callback();
        }
      }
    }
    return removed;
  }

  bool contains(EffectClosure item) => _set.contains(item);

  List<EffectClosure> get items => _list;
  HashSet<EffectClosure> get itemsSet => _set;

  void clear() {
    _set.clear();
    _list.clear();
  }

  void whenEmpty(VoidCallback callback) {
    _whenEmptyCallbacks.add(callback);
  }

  // coverage:ignore-start
  @override
  String toString() {
    return _list.toString();
  }
  // coverage:ignore-end
}

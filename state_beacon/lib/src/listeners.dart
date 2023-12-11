import 'effect_closure.dart';

class Listeners {
  final Set<EffectClosure> _set = {};
  late List<EffectClosure> _list;

  Listeners() {
    _updateList();
  }

  int get length => _set.length;

  // Updates the internal list based on the current state of the set
  void _updateList() {
    _list = _set.toList();
  }

  // Adds an item to the set and updates the list
  bool add(EffectClosure item) {
    bool added = _set.add(item);
    if (added) {
      _list.add(item);
    }
    return added;
  }

  // Removes an item from the set and updates the list
  bool remove(EffectClosure item) {
    bool removed = _set.remove(item);
    if (removed) {
      _updateList();
    }
    return removed;
  }

  // Checks if the set contains the specified item
  bool contains(EffectClosure item) {
    return _set.contains(item);
  }

  // Optionally, you might want to provide a way to access the list
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

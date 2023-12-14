part of '../base_beacon.dart';

class UndoRedoBeacon<T> extends WritableBeacon<T> {
  final int historyLimit;
  List<T> _history = [];
  int _currentHistoryIndex = -1;

  UndoRedoBeacon({T? initialValue, this.historyLimit = 10})
      : super(initialValue) {
    if (initialValue != null || isNullable) {
      _addValueToHistory(initialValue as T);
    }
  }

  bool get canUndo => _currentHistoryIndex > 0;
  bool get canRedo => _currentHistoryIndex < _history.length - 1;
  List<T> get history => List.unmodifiable(_history);

  @override
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (!_isEmpty && newValue == super.value && !force) {
      return;
    }
    super.set(newValue, force: force);
    _addValueToHistory(newValue);
    _trimHistoryIfNeeded();
  }

  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      _setValue(_history[_currentHistoryIndex]);
    }
  }

  void redo() {
    if (canRedo) {
      _currentHistoryIndex++;
      _setValue(_history[_currentHistoryIndex]);
    }
  }

  void _addValueToHistory(T newValue) {
    _currentHistoryIndex++;
    if (_currentHistoryIndex < _history.length) {
      // truncate the history if value is set after undo
      _history = _history.sublist(0, _currentHistoryIndex);
    }
    _history.add(newValue);
  }

  void _trimHistoryIfNeeded() {
    if (_history.length > historyLimit) {
      _history.removeRange(0, _history.length - historyLimit);
      _currentHistoryIndex = historyLimit - 1;
    }
  }
}

part of '../base_beacon.dart';

class UndoRedoBeacon<T> extends WritableBeacon<T> {
  final int historyLimit;
  List<T> _history = [];
  int _currentHistoryIndex = -1;

  UndoRedoBeacon(T initialValue, {this.historyLimit = 10})
      : super(initialValue) {
    _addValueToHistory(initialValue);
  }

  @override
  set value(T newValue) {
    if (newValue == super.value) {
      return;
    }
    super.value = newValue;
    _addValueToHistory(newValue);
    _trimHistoryIfNeeded();
  }

  void undo() {
    if (_currentHistoryIndex > 0) {
      _currentHistoryIndex--;
      super.value = _history[_currentHistoryIndex];
    }
  }

  void redo() {
    if (_currentHistoryIndex < _history.length - 1) {
      _currentHistoryIndex++;
      super.value = _history[_currentHistoryIndex];
    }
  }

  void _addValueToHistory(T newValue) {
    _currentHistoryIndex++;
    if (_currentHistoryIndex < _history.length) {
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

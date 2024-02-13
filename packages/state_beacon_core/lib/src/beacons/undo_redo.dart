part of '../producer.dart';

/// A beacon that allows undo/redo operations.
class UndoRedoBeacon<T> extends WritableBeacon<T> {
  /// @macro [UndoRedoBeacon]
  UndoRedoBeacon({T? initialValue, this.historyLimit = 10, super.name})
      : super(initialValue: initialValue) {
    if (initialValue != null || _isNullable) {
      _addValueToHistory(initialValue as T);
    }
  }

  /// the maximum number of history entries to keep
  final int historyLimit;
  List<T> _history = [];
  int _currentHistoryIndex = -1;

  /// Whether the beacon can be undone.
  bool get canUndo => _currentHistoryIndex > 0;

  /// Whether the beacon can be redone.
  bool get canRedo => _currentHistoryIndex < _history.length - 1;

  /// The history of values.
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

  /// Undo the last change.
  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      _setValue(_history[_currentHistoryIndex]);
    }
  }

  /// Redo the last change.
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

  @override
  void reset({bool force = false}) {
    _history.clear();
    _currentHistoryIndex = -1;
    super.reset(force: force);
  }
}

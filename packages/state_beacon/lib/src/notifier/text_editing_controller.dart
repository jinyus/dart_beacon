import 'package:flutter/widgets.dart';
import 'package:state_beacon/state_beacon.dart';

/// This is a wrapper around a [TextEditingController] that
/// allows you to hook into the controller's lifecycle.
class _TextEditingController extends TextEditingController {
  VoidCallback? disposeCallback;
  bool _disposed = false;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    disposeCallback?.call();
    super.dispose();
  }
}

/// A beacon that wraps a [TextEditingController].
class TextEditingBeacon extends WritableBeacon<TextEditingValue> {
  /// @macro [TextEditingBeacon]
  TextEditingBeacon({String? text, BeaconGroup? group, super.name})
      : super(
          initialValue: text == null
              ? TextEditingValue.empty
              : TextEditingValue(text: text),
        ) {
    group?.add(this);
    var syncing = false;

    void safeWrite(VoidCallback fn) {
      if (syncing) return;
      syncing = true;
      try {
        fn();
      } finally {
        syncing = false;
      }
    }

    _controller.addListener(() {
      safeWrite(() => set(_controller.value, force: true));
    });

    subscribe(
      (v) => safeWrite(() => _controller.value = v),
      synchronous: true,
    );

    _controller.disposeCallback = dispose;
  }

  late final _controller = _TextEditingController();

  /// The current [TextEditingController].
  TextEditingController get controller => _controller;

  /// The current string the user is editing.
  String get text => _controller.text;

  set text(String newText) {
    _controller.text = newText;
  }

  /// The currently selected [text].
  ///
  /// If the selection is collapsed, then this property gives
  /// the offset of the cursor within the text.
  TextSelection get selection => _controller.selection;

  /// Alias for controller.clear()
  void clear() => _controller.clear();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

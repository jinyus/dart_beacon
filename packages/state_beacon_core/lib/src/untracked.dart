// ignore_for_file: public_member_api_docs

import 'package:state_beacon_core/src/common.dart';

var _untrackedStack = 0;

bool isRunningUntracked() => _untrackedStack > 0;

// when running untracked, we will remove the current effects from the beacon's
//  listeners so they won't be notified when the value is accessed;
// therefore, we need to re-add them after the untracked block is done
VoidCallback? reAddListeners;

void doUntracked(void Function() fn) {
  if (isRunningUntracked()) {
    fn();
    return;
  }

  _untrackedStack++;

  try {
    fn();
  } finally {
    _untrackedStack--;
    reAddListeners?.call();
    reAddListeners = null;
  }
}

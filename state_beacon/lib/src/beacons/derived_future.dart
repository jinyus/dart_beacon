part of '../base_beacon.dart';

class DerivedFutureBeacon<T> extends DerivedBeacon<AsyncValue<T>> {
  DerivedFutureBeacon();

  var _executionID = 0;

  int startLoading() {
    super.value = AsyncLoading();
    return ++_executionID;
  }

  void setValue(int exeID, AsyncValue<T> value) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    if (exeID != _executionID) return;
    super.value = value;
  }
}

// class DerivedBeacon<T> extends LazyBeacon<T> {
//   late final VoidCallback _unsubscribe;

//   void setInternalEffectUnsubscriber(VoidCallback unsubscribe) {
//     _unsubscribe = unsubscribe;
//   }

//   DerivedBeacon();

//   @override
//   VoidCallback subscribe(
//     void Function(T value) callback, {
//     bool runImmediately = false,
//   }) {
//     final superUnsub =
//         super.subscribe(callback, runImmediately: runImmediately);

//     return () {
//       superUnsub();
//       _unsubscribe();
//     };
//   }
// }

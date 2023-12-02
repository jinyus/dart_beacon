part of '../base_beacon.dart';

class DerivedFutureBeacon<T> extends DerivedBeacon<AsyncValue<T>> {
  DerivedFutureBeacon();

  var _executionID = 0;

  int startLoading() {
    super.forceSetValue(AsyncLoading());
    return ++_executionID;
  }

  void setAsyncValue(int exeID, AsyncValue<T> value) {
    // If the execution ID is not the same as the current one,
    // then this is an old execution and we should ignore it
    if (exeID != _executionID) return;
    super.forceSetValue(value);
  }
}

part of '../base_beacon.dart';

abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  AsyncBeacon({super.initialValue, super.debugLabel});

  Future<T> toFuture();
}

part of '../base_beacon.dart';

abstract class AsyncBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  AsyncBeacon({super.initialValue});

  Future<T> toFuture();
}

// ignore_for_file: constant_identifier_names

/// A callback that takes no arguments and returns no data.
typedef VoidCallback = void Function();

/// The status of a consumer.
typedef Status = int;

/// The consumer is clean.
const CLEAN = 0;

/// The consumer is maybe dirty. Check its sources.
const CHECK = 1;

/// The consumer is dirty.
const DIRTY = 2;

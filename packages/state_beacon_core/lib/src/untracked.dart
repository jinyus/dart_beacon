part of 'producer.dart';

/// The current untracked effect.
Effect? untrackedConsumer;

/// Whether the current effect is running untracked.
bool isRunningUntracked() => untrackedConsumer != null;

/// Runs a function untracked.
void doUntracked(VoidCallback fn) {
  if (isRunningUntracked()) {
    fn();
    return;
  }

  untrackedConsumer =
      currentConsumer is Effect ? currentConsumer! as Effect : null;

  fn();

  untrackedConsumer = null;
}

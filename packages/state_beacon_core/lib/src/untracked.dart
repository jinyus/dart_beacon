part of 'producer.dart';

/// The current untracked effect.
int untrackedDepth = 0;

/// Runs a function untracked.
void doUntracked(VoidCallback fn) {
  if (untrackedDepth > 0) {
    fn();
    return;
  }

  untrackedDepth++;

  final prevConsumer = currentConsumer;
  currentConsumer = null;

  try {
    fn();
  } finally {
    currentConsumer = prevConsumer;
    untrackedDepth--;
  }
}

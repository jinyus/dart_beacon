var _untrackedStack = 0;

bool isRunningUntracked() => _untrackedStack > 0;

void doUntracked(void Function() fn) {
  _untrackedStack++;
  fn();
  _untrackedStack--;
}

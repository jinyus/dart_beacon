const k1ms = Duration(milliseconds: 1);
const k10ms = Duration(milliseconds: 10);

Future<void> delay([Duration? duration]) {
  return Future.delayed(duration ?? (k10ms * 1.1));
}

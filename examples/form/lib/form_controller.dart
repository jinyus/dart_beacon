import 'package:state_beacon/state_beacon.dart';

class FormController with BeaconController {
  final _emailRegexp = RegExp(
    r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)',
  );

  late final username = TextEditingBeacon(text: '', group: B);
  late final email = TextEditingBeacon(text: '', group: B);
  late final password = TextEditingBeacon(text: '', group: B);
  late final passwordConfirm = TextEditingBeacon(text: '', group: B);

  // this allows us to hide the errors until
  // the user starts typing or press submit
  late final _hasSubmitted = B.writable(false);

  late final usernameError = B.derived(() {
    final value = username.value.text;

    // don't show error until the user types or submit
    if (!_hasSubmitted.value && value.isEmpty) return null;

    if (value.length < 4) return 'Enter at least 4 characters';

    return null;
  });

  late final emailError = B.derived(() {
    final value = email.value.text;

    if (!_hasSubmitted.value && value.isEmpty) return null;

    if (value.length < 6 || !_emailRegexp.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  });

  late final passwordError = B.derived(() {
    final (pw1, pw2) = (password.value.text, passwordConfirm.value.text);

    final combined = '$pw1$pw2';

    if (!_hasSubmitted.value && combined.isEmpty) return null;

    if (pw1 != pw2) return 'Passwords are not the same';

    if (combined.length < 14) {
      return 'Password must be at least 7 characters long';
    }

    return null;
  });

  bool get isValid =>
      (usernameError.peek(), emailError.peek(), passwordError.peek()) ==
      (null, null, null);

  String? submit() {
    _hasSubmitted.value = true;

    if (!isValid) return null;

    return 'Username: ${username.text}\n'
        'Password: ${password.text}\n'
        'Email: ${email.text}';
  }
}

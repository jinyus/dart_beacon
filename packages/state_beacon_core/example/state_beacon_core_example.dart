// ignore_for_file: unused_import

import 'package:state_beacon_core/state_beacon_core.dart';

void main() {
  final name = Beacon.writable("Bob");
  final age = Beacon.writable(20);
  final college = Beacon.writable("MIT");

  Beacon.effect(() {
    var msg = '${name.value} is ${age.value} years old';

    if (age.value > 21) {
      msg += ' and can go to ${college.value}';
    }
    print(msg);
  });

  // prints "Alice is 20 years old"
  name.value = "Alice";

  // prints "Alice is 21 years old"
  age.value = 21;

  // prints "Alice is 21 years old"
  college.value = "Stanford";

  // prints "Alice is 22 years old and can go to Stanford"
  age.value = 22;

  // prints "Alice is 22 years old and can go to Harvard"
  college.value = "Harvard";
}

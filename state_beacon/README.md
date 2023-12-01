### Beacon - A reactive primitive for dart and flutter

## Usage

```dart
final name = Beacon.writable("Bob");
final age = Beacon.writable(20);
final college = Beacon.writable("MIT");

Beacon.createEffect(() {
  var msg = '${name.value} is ${age.value} years old';

  if (age.value > 21) {
      msg += ' and can go to ${college.value}';
  }
  print(msg);
});

name.value = "Alice"; // prints "Alice is 20 years old"
age.value = 21; // prints "Alice is 21 years old"
college.value = "Stanford"; // prints "Alice is 21 years old"
age.value = 22; // prints "Alice is 22 years old and can go to Stanford"
college.value = "Harvard"; // prints "Alice is 22 years old and can go to Harvard"
```

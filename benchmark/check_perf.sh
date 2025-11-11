#!/bin/bash
firstArgs=("$@")

# if arg is new, run performance tests with changes
if [ "${firstArgs[0]}" = "new" ]; then
  dart run new_code/bin/performance_test.dart
else
  dart run old_code/bin/performance_test.dart
fi
#!/bin/bash
firstArgs=("$@")

dir=$(dirname "$0")


# if arg is new, run performance tests with changes
if [ "${firstArgs[0]}" = "new" ]; then
  dart run "$dir/new_code/bin/performance_test.dart"
else
  dart run "$dir/old_code/bin/performance_test.dart"
fi
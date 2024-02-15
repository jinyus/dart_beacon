#!/bin/bash

# The first argument is the action (test or publish)
ACTION=$1
# The second argument is the target (core, flutter, or example)
TARGET=$2

CURRENT_DIR=$(pwd)

# Function to handle testing
test_target() {
    cd $CURRENT_DIR # for "all" tests, we need to be in the root directory

    if [ "$1" == "core" ]; then
        echo "testing core"
        cd packages/state_beacon_core &&
            flutter test --coverage
    elif [ "$1" == "flutter" ]; then
        echo "testing flutter"
        cd packages/state_beacon &&
            flutter test --coverage
    elif [ "$1" == "example" ]; then
        echo "testing flutter_main example"
        cd examples/flutter_main &&
            flutter test
        echo "testing shopping_cart example"
        cd ../shopping_cart &&
            flutter test
    elif [ "$1" == "all" ]; then
        test_target "core" &&
            test_target "flutter" &&
            test_target "example"
    else
        echo -e "unknown test \"$1\" \nValid tests are: core, flutter, example, all"
    fi
}

# Function to handle publishing
publish_target() {
    if [ "$1" == "core" ]; then
        echo "publishing core"
        cd packages/state_beacon_core
        dart pub publish
    elif [ "$1" == "flutter" ]; then
        echo "publishing flutter"
        cd packages/state_beacon
        dart pub publish
    elif [ "$1" == "lint" ]; then
        echo "publishing lint"
        cd packages/state_beacon_lint
        dart pub publish
    else
        echo -e "unknown package \"$1\" \nValid packages are: core, flutter, lint"
    fi
}

# Main logic to decide whether to test or publish based on the first argument
if [ "$ACTION" == "test" ]; then
    test_target $TARGET
elif [ "$ACTION" == "publish" ]; then
    publish_target $TARGET
else
    echo -e "Unknown action \"$ACTION\" \nValid actions are: test, publish"
fi

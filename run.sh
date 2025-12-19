#!/bin/bash

# The first argument is the action (test or publish)
ACTION=$1
# The second argument is the target (core, flutter, or example)
TARGET=$2
# Store additional arguments in a variable
ADDITIONAL_ARGS="${@:3}"

CURRENT_DIR=$(pwd)

# Function to handle testing
test_target() {
    cd $CURRENT_DIR # for "all" tests, we need to be in the root directory

    if [ "$1" == "core" ]; then
        echo "testing core"
        cd packages/state_beacon_core &&
            flutter test --coverage --timeout 5s $2

    elif [ "$1" == "flutter" ]; then
        echo "testing flutter"
        cd packages/state_beacon_flutter &&
            flutter test --coverage $2

    elif [ "$1" == "main" ]; then
        echo "testing main"
        cd packages/state_beacon &&
            flutter test --coverage $2

    elif [ "$1" == "example" ]; then
        echo "testing flutter_main example"
        cd examples/flutter_main &&
            flutter test $2 &&
            echo "testing shopping_cart example" &&
            cd ../shopping_cart &&
            flutter test $2 &&
            echo "testing counter example" &&
            cd ../counter &&
            flutter test $2  &&
            echo "testing form example" &&
            cd ../form &&
            flutter test $2 &&
            echo "testing tictactoe example" &&
            cd ../tic_tac_toe &&
            flutter test $2 &&
            echo "testing snake example" &&
            cd ../snake_game &&
            flutter test $2 &&
            echo "testing splash page example" &&
            cd ../splash_page &&
            flutter test $2
    elif [ "$1" == "all" ]; then
        test_target "core" "$2" &&
            test_target "flutter" "$2" &&
            test_target "example" "$2"
    else
        echo -e "unknown test \"$1\" \nValid tests are: core, flutter, example, all"
    fi
}

# dont publish tests
publish_and_update_pubignore() {
    # Backup pubspec_overrides.yaml if it exists
    if [ -f "pubspec_overrides.yaml" ]; then
        mv pubspec_overrides.yaml pubspec_overrides.yaml.backup
    fi &&
    cp .gitignore .pubignore &&
        echo test/ | tee -a .pubignore &&
        echo pubspec_overrides.yaml.backup | tee -a .pubignore &&
        dart pub publish "$@"
    # Restore pubspec_overrides.yaml if it was backed up
    if [ -f "pubspec_overrides.yaml.backup" ]; then
        mv pubspec_overrides.yaml.backup pubspec_overrides.yaml
    fi &&
    rm .pubignore
}

# Function to handle publishing
publish_target() {
    cp Readme.md packages/state_beacon_core/README.md &&
        cp Readme.md packages/state_beacon/README.md &&
        if [ "$1" == "core" ]; then
            echo "publishing core"
            cd packages/state_beacon_core &&
                publish_and_update_pubignore $2

        elif [ "$1" == "flutter" ]; then
            echo "publishing flutter"
            cd packages/state_beacon_flutter &&
                publish_and_update_pubignore $2

        elif [ "$1" == "main" ]; then
            echo "publishing main"
            cd packages/state_beacon &&
                publish_and_update_pubignore $2

        elif [ "$1" == "lint" ]; then
            echo "publishing lint"
            cd packages/state_beacon_lints
            dart pub publish $2
        else
            echo -e "unknown package \"$1\" \nValid packages are: core, flutter, lint"
        fi
}

deps() {
    cd $CURRENT_DIR/packages/state_beacon_core &&
        flutter pub get &&
        cd $CURRENT_DIR/packages/state_beacon &&
        flutter pub get &&
        cd $CURRENT_DIR/packages/state_beacon_flutter &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/flutter_main &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/counter &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/shopping_cart &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/vgv_best_practices &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/auth_flow &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/skeleton &&
        flutter pub get &&
        cd $CURRENT_DIR/examples/github_search &&
        flutter pub get
        cd $CURRENT_DIR/examples/form &&
        flutter pub get
        cd $CURRENT_DIR/examples/snake_game &&
        flutter pub get
        cd $CURRENT_DIR/examples/splash_page &&
        flutter pub get
        cd $CURRENT_DIR/examples/tic_tac_toe &&
        flutter pub get
        cd $CURRENT_DIR/examples/bench &&
        flutter pub get

}

# Main logic to decide whether to test or publish based on the first argument
if [ "$ACTION" == "test" ]; then
    test_target $TARGET $ADDITIONAL_ARGS
elif [ "$ACTION" == "pub" ]; then
    publish_target $TARGET $ADDITIONAL_ARGS
elif [ "$ACTION" == "deps" ]; then
    deps
else
    echo -e "Unknown action \"$ACTION\" \nValid actions are: test, publish"
fi

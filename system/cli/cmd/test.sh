#!/bin/bash

set -eu

CMD=${1:-}

export TEST=true

case $CMD in
    summarize)
        echo "test | | Test flapctl's commands."
        ;;
    help)
        echo "test | [--only <test_suite>] | Test flapctl's commands." | column -t -s "|"
        ;;
    ""|*)
        echo '* [test] Running tests.'
        EXIT=0

        mapfile -t TEST_TO_RUN < <(ls "$FLAP_DIR/system/cli/tests")

        if [ "$#" != "0" ]
        then
            TEST_TO_RUN=("$@")
        fi

        for test in "${TEST_TO_RUN[@]}"
        do
            test=$(basename "$test" .spec.sh)
            if [ -f "$FLAP_DIR/system/cli/tests/$test.spec.sh" ]
            then
                echo "  + Running '$test'..."
                {
                    "$FLAP_DIR/system/cli/tests/$test.spec.sh" &&
                    echo "  ✅ All tests passed for '$test'."
                } || {
                    echo "  ❌ Some tests failed for '$test'."
                    EXIT=1
                }
                echo ""
            fi
        done
        exit $EXIT
        ;;
esac

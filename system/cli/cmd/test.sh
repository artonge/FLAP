#!/bin/bash

set -e

CMD=$1

case $CMD in
    summarize)
        echo "test | | Test manager's commands."
        ;;
    help)
        echo "test | [--only <test_suite>] | Test manager's commands." | column -t -s "|"
        ;;
    ""|*)
        echo "Running tests..."
        EXIT=0

        TEST_TO_RUN=$(ls $FLAP_DIR/system/cli/tests)

        if [ "$#" != "0" ]
        then
            TEST_TO_RUN=($@)
        fi

        for test in $TEST_TO_RUN
        do
            test=$(basename $test .spec.sh)
            if [ -f $FLAP_DIR/system/cli/tests/$test.spec.sh ]
            then
                echo "  + Running '$test'..."
                {
                    $FLAP_DIR/system/cli/tests/$test.spec.sh &&
                    echo "  ✅ All tests passed for '$test'."
                } || {
                    echo "  ❌ Some tests failed for '$test'."
                    EXIT=1
                }
                echo ""
            fi
        done
        ;;
esac

exit $EXIT
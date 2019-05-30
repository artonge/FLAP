#!/bin/bash

set -e

CMD=$1
ARGS=($@)
ARGS=${ARGS[@]:0}

TEST_TO_RUN=$(ls $FLAP_DIR/system/cli/tests)

if [ "$#" != "0" ]
then
    TEST_TO_RUN=$ARGS
fi

case $CMD in
    ""|*)
        echo "Running tests..."

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
                }
                echo ""
            fi
        done
        ;;
    summarize)
        echo "test | | Test manager's commands."
        ;;
    help)
        echo "test | [--only <test_suite>] | Test manager's commands." | column --table --separator "|"
        ;;
esac

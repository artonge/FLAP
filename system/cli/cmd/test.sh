#!/bin/bash

set -e

CMD=$1
only=$2

case $CMD in
    ""|--only)
        echo "Running tests..."
        if [ -f $FLAP_DIR/system/cli/tests/$only.spec.sh ]
        then
            test=$only.spec.sh
            echo "  + Running '$test'..."
            {
                $FLAP_DIR/system/cli/tests/$test &&
                echo "  ✅ All tests passes for '$test'."
            } || {
                echo "  ❌ Some tests failed for '$test'."
                exit 1
            }

            exit 0
        fi

        for test in $(ls $FLAP_DIR/system/cli/tests)
        do
            if [ -f $FLAP_DIR/system/cli/tests/$test ]
            then
                echo "  + Running '$test'..."
                {
                    $FLAP_DIR/system/cli/tests/$test &&
                    echo "  ✅ All tests passes for '$test'."
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
    help|*)
        echo "test | [--only <test_suite>] | Test manager's commands." | column --table --separator "|"
        ;;
esac

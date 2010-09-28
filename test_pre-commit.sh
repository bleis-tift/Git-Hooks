#! /bin/sh

test_precommit()
{
    git checkout master >/dev/null 2>&1
    ./pre-commit >/dev/null 2>&1
    assertEquals 1 $?

    git checkout -b hoge >/dev/null 2>&1
    ./pre-commit >/dev/null 2>&1
    assertEquals 0 $?

    git checkout master >/dev/null 2>&1
    git branch -D hoge >/dev/null 2>&1
}

. ./shunit2/src/shell/shunit2

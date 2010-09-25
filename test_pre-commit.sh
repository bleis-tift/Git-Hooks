#! /bin/sh

test_precommit()
{
    git checkout master 2>/dev/null
    ./pre-commit
    assertEquals 1 $?

    git checkout -b hoge 2>/dev/null
    ./pre-commit
    assertEquals 0 $?

    git checkout master 2>/dev/null
    git branch -D hoge >/dev/null
}

. ./shunit2/src/shell/shunit2

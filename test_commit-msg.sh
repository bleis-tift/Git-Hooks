#! /bin/sh

test_commitmsg()
{
    git checkout master >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge" "$(cat test4commitmsg)"

    git checkout -b "id/42" >/dev/null 2>&1
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 42" "$(cat test4commitmsg)"

    git checkout -b "bug/id/41" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 41" "$(cat test4commitmsg)"

    git checkout -b "id/10/aaa" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 10" "$(cat test4commitmsg)"

    git checkout -b "a/id/0/b" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 0" "$(cat test4commitmsg)"

    git checkout master >/dev/null 2>&1
    git branch -D "id/42" >/dev/null 2>&1
    git branch -D "bug/id/41" >/dev/null 2>&1
    git branch -D "id/10/aaa" >/dev/null 2>&1
    git branch -D "a/id/0/b" >/dev/null 2>&1
    rm test4commitmsg
}

. ./shunit2/src/shell/shunit2

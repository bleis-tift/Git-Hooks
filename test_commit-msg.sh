#! /bin/sh

test_commitmsg()
{
    git checkout master >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge" "$(cat test4commitmsg)"

    git checkout -b "ref/42" >/dev/null 2>&1
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 42" "$(cat test4commitmsg)"

    git checkout -b "bug/ref/41" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 41" "$(cat test4commitmsg)"

    git checkout -b "ref/10/aaa" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 10" "$(cat test4commitmsg)"

    git checkout -b "a/ref/0/b" >/dev/null 2>&1
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge refs 0" "$(cat test4commitmsg)"

    git checkout master >/dev/null 2>&1
    git branch -D "ref/42" >/dev/null 2>&1
    git branch -D "bug/ref/41" >/dev/null 2>&1
    git branch -D "ref/10/aaa" >/dev/null 2>&1
    git branch -D "a/ref/0/b" >/dev/null 2>&1
    rm test4commitmsg
}

. ./shunit2/src/shell/shunit2

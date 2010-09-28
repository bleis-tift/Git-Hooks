#! /bin/sh

test_commitmsg()
{
    git checkout master 2>/dev/null
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge" "$(cat test4commitmsg)"

    git checkout -b "ref/42" 2>/dev/null
    ./commit-msg test4commitmsg
    assertEquals "hoge ref 42" "$(cat test4commitmsg)"

    git checkout -b "bug/ref/41" 2>/dev/null
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge ref 41" "$(cat test4commitmsg)"

    git checkout -b "ref/10/aaa" 2>/dev/null
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge ref 10" "$(cat test4commitmsg)"

    git checkout -b "a/ref/0/b" 2>/dev/null
    echo hoge > test4commitmsg
    ./commit-msg test4commitmsg
    assertEquals "hoge ref 0" "$(cat test4commitmsg)"

    git checkout master 2>/dev/null
    git branch -D "ref/42" >/dev/null
    git branch -D "bug/ref/41" >/dev/null
    git branch -D "ref/10/aaa" >/dev/null
    git branch -D "a/ref/0/b" >/dev/null
    rm test4commitmsg
}

. ./shunit2/src/shell/shunit2

#! /bin/sh

. pre-commit.sh

test_getGitBranchName()
{
    git checkout master 2>/dev/null
    assertEquals "master" "$(getGitBranchName)"

    git checkout -b hoge 2>/dev/null
    assertEquals "hoge" "$(getGitBranchName)"

    git checkout master 2>/dev/null
    git branch -D hoge >/dev/null
    assertEquals "master" "$(getGitBranchName)"
}

. ./shunit2/src/shell/shunit2

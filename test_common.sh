#! /bin/sh

. ./common.sh

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

test_isOnMasterBranch()
{
    git checkout master 2>/dev/null
    isOnMasterBranch
    assertEquals 0 $?

    git checkout -b hoge 2>/dev/null
    isOnMasterBranch
    assertEquals 1 $?

    git checkout master 2>/dev/null
    git branch -D hoge >/dev/null
}

test_appendMsgTo1stLine()
{
    # 2行のパターン
    cat << EOF > ./fortest.txt
first line
second line
EOF

    appendMsgTo1stLine fortest.txt "hoge"
    assertEquals "first line hoge" "$(cat ./fortest.txt | head -1)"
    assertEquals "second line" "$(cat ./fortest.txt | head -2 | tail -1)"

    # 1行のパターン
    echo "first line" > ./fortest.txt

    appendMsgTo1stLine fortest.txt "piyo"
    assertEquals "first line piyo" "$(cat ./fortest.txt)"

    # 空のパターン
    rm ./fortest.txt
    touch ./fortest.txt

    appendMsgTo1stLine fortest.txt "foo"
    assertEquals "foo" "$(cat ./fortest.txt)"

    rm ./fortest.txt
}

. ./shunit2/src/shell/shunit2

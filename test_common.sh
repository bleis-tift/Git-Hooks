#! /bin/sh

. ./common.sh

test_getGitBranchName()
{
    git checkout master >/dev/null 2>&1
    assertEquals "master" "$(getGitBranchName)"

    git checkout -b hoge >/dev/null 2>&1
    assertEquals "hoge" "$(getGitBranchName)"

    git checkout master >/dev/null 2>&1
    git branch -D hoge >/dev/null 2>&1
    assertEquals "master" "$(getGitBranchName)"
}

test_isOnMasterBranch()
{
    git checkout master >/dev/null 2>&1
    isOnMasterBranch
    assertEquals 0 $?

    git checkout -b hoge >/dev/null 2>&1
    isOnMasterBranch
    assertEquals 1 $?

    git checkout master >/dev/null 2>&1
    git branch -D hoge >/dev/null 2>&1
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

test_extractTicketId()
{
    git checkout master >/dev/null 2>&1
    assertEquals "" "$(extractTicketId)"

    git checkout -b ref/42 >/dev/null 2>&1
    assertEquals "refs 42" "$(extractTicketId)"

    # 前は一階層のみ階層化可能
    git checkout -b bug/ref/10 >/dev/null 2>&1
    assertEquals "refs 10" "$(extractTicketId)"

    # 後ろはどれだけついてもOK
    git checkout -b ref/9/some/description >/dev/null 2>&1
    assertEquals "refs 9" "$(extractTicketId)"

    # 両方ついてもOK
    git checkout -b issue/ref/8/some/description >/dev/null 2>&1
    assertEquals "refs 8" "$(extractTicketId)"

    git checkout master >/dev/null 2>&1
    git branch -D ref/42 >/dev/null 2>&1
    git branch -D bug/ref/10 >/dev/null 2>&1
    git branch -D ref/9/some/description >/dev/null 2>&1
    git branch -D issue/ref/8/some/description >/dev/null 2>&1
}

test_hasTicketId()
{
    git checkout -b "test/for/hasTicketId" >/dev/null 2>&1
    touch test4hasticketid1
    git add .
    git commit -m "without ticket id." >/dev/null 2>&1
    hash="$(git log -1 | head -1)"
    assertEquals "false" "$(hasTicketId ${hash##commit })"

    touch test4hasticketid2
    git add .
    git commit -m "with ticket id. refs 42" >/dev/null 2>&1
    hash="$(git log -1 | head -1)"
    assertEquals "true" "$(hasTicketId ${hash##commit })"

    git checkout master >/dev/null 2>&1
    git branch -D "test/for/hasTicketId" >/dev/null 2>&1
}

test_extractParents()
{
    git checkout -b "test/for/extractParents" >/dev/null 2>&1
    old="$(git log -1 | head -1)"
    touch test4extractparents
    git add .
    git commit -m "test" >/dev/null 2>&1
    new="$(git log -1 | head -1)"
    assertEquals ${old##commit } "$(extractParents ${new##commit })"

    git checkout master >/dev/null 2>&1
    git branch -D "test/for/extractParents" >/dev/null 2>&1
}

. ./shunit2/src/shell/shunit2

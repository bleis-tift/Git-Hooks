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

test_extractTicketId()
{
    git checkout master 2>/dev/null
    assertEquals "" "$(extractTicketId)"

    git checkout -b ref/42 2>/dev/null
    assertEquals "refs 42" "$(extractTicketId)"

    # 前は一階層のみ階層化可能
    git checkout -b bug/ref/10 2>/dev/null
    assertEquals "refs 10" "$(extractTicketId)"

    # 後ろはどれだけついてもOK
    git checkout -b ref/9/some/description 2>/dev/null
    assertEquals "refs 9" "$(extractTicketId)"

    # 両方ついてもOK
    git checkout -b issue/ref/8/some/description 2>/dev/null
    assertEquals "refs 8" "$(extractTicketId)"

    git checkout master 2>/dev/null
    git branch -D ref/42 >/dev/null
    git branch -D bug/ref/10 >/dev/null
    git branch -D ref/9/some/description >/dev/null
    git branch -D issue/ref/8/some/description >/dev/null
}

test_hasTicketId()
{
    git checkout -b "test/for/hasTicketId" 2>/dev/null
    touch test4hasticketid1
    git add .
    git commit -m "without ticket id." >/dev/null
    hash="$(git log -1 | head -1)"
    assertEquals "false" "$(hasTicketId ${hash##commit })"

    touch test4hasticketid2
    git add .
    git commit -m "with ticket id. refs 42" >/dev/null
    hash="$(git log -1 | head -1)"
    assertEquals "true" "$(hasTicketId ${hash##commit })"

    git checkout master 2>/dev/null
    git branch -D "test/for/hasTicketId" >/dev/null
}

test_extractParents()
{
    git checkout -b "test/for/extractParents" 2>/dev/null
    old="$(git log -1 | head -1)"
    touch test4extractparents
    git add .
    git commit -m "test" >/dev/null
    new="$(git log -1 | head -1)"
    assertEquals ${old##commit } "$(extractParents ${new##commit })"

    git checkout master 2>/dev/null
    git branch -D "test/for/extractParents" >/dev/null
}

. ./shunit2/src/shell/shunit2

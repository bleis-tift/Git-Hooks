#! /bin/sh

getGitBranchName()
{
    branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
            "$(git describe --contains --all HEAD)"
    echo ${branch##refs/heads/}
}

isOnMasterBranch()
{
    if [ "$(getGitBranchName)" = "master" ]; then
        return 0
    fi
    return 1
}

appendMsgTo1stLine()
{
    file="$1"
    contents=" $2"

    cp $file ${file}.tmp
    first=$(cat $file | head -1)$contents
    echo $first > $file
    cat ${file}.tmp | tail +2 >> $file
    rm ${file}.tmp
}


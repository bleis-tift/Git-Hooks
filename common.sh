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
    if [ -s $1 ]; then
        sed -i '1s/$/ '$2'/' $1
    else
        echo $2 > $1
    fi
}

extractTicketId()
{
    echo "$(getGitBranchName)" \
    | awk '/(.+\/)?ref\/[0-9]+(\/.+)?/' | sed 's/.*ref\/\([0-9]*\).*/ref \1/'
}


function issue {
    if [ -z "${1// }" ] || [ -z "${2// }" ]
    then
        echo -e Usage: issue \<start\|finish\|switch\> \<issue number\>
    else
        case $1 in
        start)
            issue_start $2
            ;;
        finish)
            issue_finish $2
            ;;
        switch)
            issue_switch $2
            ;;
        *)
            echo -e Usage: issue \<start\|finish\|switch\> \<issue number\>
            ;;
        esac
    fi
}

function issue_start {
    project=$(pwd | sed -E 's/\/sites\///' | sed -E 's/\/htdocs//' | awk '{print toupper($0)}')
    git flow feature start $project-$1
}

function issue_finish {
    project=$(pwd | sed -E 's/\/sites\///' | sed -E 's/\/htdocs//' | awk '{print toupper($0)}')

    git add -A
    git commit -m "Cleanup"
    git checkout develop
    git pull origin develop
    git checkout feature/$project-$1
    git merge develop
    git checkout develop
    git merge --squash feature/$project-$1
    git commit -m $project-$1
    git branch -d feature/$project-$1
}

function issue_switch {
    project=$(pwd | sed -E 's/\/sites\///' | sed -E 's/\/htdocs//' | awk '{print toupper($0)}')
    git checkout feature/$project-$1
}

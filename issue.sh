function project {
    project=$(cat composer.json | grep -m 1 name | sed -E 's/.*\///' | sed -E 's/\",?//' | awk '{print toupper($0)}')

    if [ -z $project ];
    then
        project=$(pwd | sed -E 's/.*(www\/|sites\/)//' | sed -E 's/\/htdocs//' | awk '{print toupper($0)}')
    fi

    echo $project
}

function issue {
    isNumber='^[0-9]+$'

    if [ -z "${1// }" ]
    then
        echo -e Usage: issue \[start\|s\|finish\|f\|switch\|sw\] \<issue number\>
    else
        if [[ $1 =~ $isNumber ]]
        then
            project=$(project)
            isExistingBranch=$(git branch -l | grep -c $project-$1)

            if [[ $isExistingBranch =~ $isNumber ]] && [ $isExistingBranch -gt 0 ]
            then
                issue_switch $1
            else
                issue_start $1
            fi
        else
            case $1 in
            start)
                issue_start $2
                ;;
            s)
                issue_start $2
                ;;
            finish)
                issue_finish $2
                ;;
            f)
                issue_finish $2
                ;;
            switch)
                issue_switch $2
                ;;
            sw)
                issue_switch $2
                ;;
            *)
                echo -e Usage: issue \[start\|s\|finish\|f\|switch\|sw\] \<issue number\>
                ;;
            esac
        fi
    fi
}

function issue_start {
    project=$(project)

    git flow feature start $project-$1
}

function issue_finish {
    project=$(project)

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
    project=$(project)

    git checkout feature/$project-$1
}

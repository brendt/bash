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
            isExistingBranch=$(git branch -l | grep -c feature/$project-$1)

            if [[ $isExistingBranch =~ $isNumber ]] && [ $isExistingBranch -gt 0 ]
            then
                issue_switch $1
            else
                issue_start $1
            fi
        else
            case $1 in
            get)
                issue_get
                ;;
            number)
                issue_get
                ;;
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
            done)
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

function issue_get {
    echo $(git branch 2>/dev/null | grep '*' | sed "s/.*$(project)-//")
}

function issue_start {
    project=$(project)

    git checkout -b feature/$project-$1 develop
}

function issue_finish {
    project=$(project)
    issue=$1

    if [ !$issue ]
    then
        issue=$(issue_get)
    fi

    git add -A
    git commit -m "$project-$issue: done"
    git checkout develop
    git pull origin develop
    git checkout feature/$project-$issue
    git merge develop
    git checkout develop
    git merge --no-ff feature/$project-$issue -m "$project-$issue: merged into develop"
    git branch -d feature/$project-$issue
}

function issue_switch {
    project=$(project)

    git checkout feature/$project-$1
}

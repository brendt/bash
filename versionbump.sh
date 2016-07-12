versionFile="composer.json"
changelogFile="CHANGELOG.md"

function major() {
    bumpVersion "major"
}

function minor() {
    bumpVersion "minor"
}

function patch() {
    bumpVersion "patch"
}

function bumpVersion() {
    if [ ! -f "$versionFile" ];
    then
        echo -e "> ${red}No ${versionFile} found${normal}"
    elif [ ! -d ".git" ];
    then
        echo -e "> ${red}No git repository found${normal}"
    elif ! grep --quiet gitflow .git/config
    then
        echo -e "> ${red}Git flow is not enabled${normal}"
    else
        action=$1
        commitChanges

        if [ ! -f "CHANGELOG.md" ]
        then
            touch CHANGELOG.md
            echo "# Changelog" > CHANGELOG.md
            git add CHANGELOG.md
            git commit -m "Add CHANGELOG.md"
        fi

        previousVersion=$(getVersion)
        IFS='.' read -ra version <<< "$previousVersion"

        case $action in
        "major")
            ((version[0]++))
            ((version[1]=0))
            ((version[2]=0))
            ;;
        "minor")
            ((version[1]++))
            ((version[2]=0))
            ;;
        "patch")
            ((version[2]++))
            ;;
        esac

        bumpedVersion=${version[0]}.${version[1]}.${version[2]}
        changelogHasVersion=$(grep -c "${version}" "CHANGELOG.md")
        if [ $action == "major" ] && [ $changelogHasVersion == 0 ]
        then
            echo -e "> ${red}No changelog entry found for this major version (${bumpedVersion}) in ${changelogFile}. Please add it first.${normal}"
        else
            releaseVersion $action $previousVersion $bumpedVersion
        fi
    fi
}

function commitChanges() {
    echo -e "> ${green}Updating develop${normal}"
    git checkout develop
    git add -A
    git commit -m "bump"
    git pull origin develop

    echo -e ""
    echo -e "> ${green}Updating master${normal}"
    git checkout master
    git pull origin master

    echo -e ""
    echo -e "> ${green}Merging master into develop${normal}"
    git checkout develop
    git merge master
}

function getVersion() {
    gitDescribeErrorCount=$(git describe 2> >(grep -c "fatal"))

    isNumber='^[0-9]+$'
    if [[ $gitDescribeErrorCount =~ $isNumber ]] && [ $gitDescribeErrorCount -gt 0 ]
    then
        tag='0.0.0'
    else
        tag=$(git describe --tag)
        tag=${tag%-*}
        tag=${tag%-*}
    fi

    echo $tag

}

function releaseVersion() {
    versionType=$1
    previousVersion=$2
    currentVersion=$3
    color=${red}

    if [ "$versionType" == "patch" ]; then
        color=${green}
    fi

    if [ "$versionType" == "minor" ]; then
        color=${orange}
    fi

    echo -e ""
    echo -e "> ${green}Bumping version${normal}"
    echo -e "  Creating a new ${color}$versionType${normal} update. Current version is ${color}$currentVersion${normal} (previous was $previousVersion)"

    gitflowErrorCount=$(git flow release start ${currentVersion} 2> >(grep -c "There is an existing release branch"))

    isNumber='^[0-9]+$'
    if [[ $gitflowErrorCount =~ $isNumber ]] && [ $gitflowErrorCount -gt 0 ]
    then
        echo -e ""
        echo -e "> ${red}There is an existing release branch, finish or delete that one first.${normal}"
    else
        # updateComposerVersion $currentVersion
        # git add composer.*
        # git commit -m "Bump composer version to $currentVersion"
        git tag -a $currentVersion -m "$currentVersion"
        git flow release finish ${currentVersion}

        echo -e ""
        echo -e "> ${green}Pushing changes${normal}"
        git push origin master --tags
        git checkout develop
        git push origin develop

        echo -e ""
        echo -e "> ${green}We're at version $currentVersion now. All done.${normal}"
    fi
}

function updateComposerVersion() {
    sed -Ei '.bak' 's/\"version\":[[:space:]]*\"[0-9]*\.?[0-9]*\.?[0-9]*\"/\"version\": \"'$1'\"/' composer.json
}

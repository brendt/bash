# TODO: geen tag wanneer master up-to-date is met develop

versionFile="composer.json"
changelogFile="CHANGELOG.md"
release=true

function major() {
    checkRelease $1
    bumpVersion "major"
}

function minor() {
    checkRelease $1
    bumpVersion "minor"
}

function patch() {
    checkRelease $1
    bumpVersion "patch"
}

function checkRelease() {
    if [ $# -eq 1 ]
    then
        if [ "$1" == '--release' ]
        then
            release=true
        elif [ "$1" == '--no-release' ]
        then
            release=false
        fi
    fi
}

function version() {
    gitDescribeErrorCount=$(git describe 2> >(grep -c "fatal"))

    isNumber='^[0-9]+$'
    if [[ $gitDescribeErrorCount =~ $isNumber ]] && [ $gitDescribeErrorCount -gt 0 ]
    then
        tag=$(composerVersion)
    else
        tag=$(git describe --tag)
        IFS='.' read -ra version <<< "$tag"

        if [ ${#version[@]} -eq 3 ]
        then
            tag=${tag%-*}
            tag=${tag%-*}
        else
            tag=$(composerVersion)
        fi
    fi

    echo $tag
}

function composerVersion() {
    isNumber='^[0-9]+$'
    composerHasVersion=$(cat composer.json | grep -c "version")

    if [[ $composerHasVersion =~ $isNumber ]] && [ $composerHasVersion -gt 0 ]
    then
        tag=$(cat composer.json | grep version | sed -E "s/.*version\":[[:space:]]\"//" | sed -E "s/\", ?//")
    else
        tag='0.0.0'
    fi

    echo $tag
}

function commitChanges() {
    echo -e "> ${green}Updating develop${normal}"
    git checkout develop
    git add -A
    git commit -m "Comitting all open changes"
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

        if [ ! -f "CHANGELOG.md" ]
        then
            touch CHANGELOG.md
            echo "# Changelog" > CHANGELOG.md
            git add CHANGELOG.md
            git commit -m "Add CHANGELOG.md"
        fi

        commitChanges

        previousVersion=$(version)
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
            echo -e ""
            echo -e "> ${red}No changelog entry found for this major version (${bumpedVersion}) in ${changelogFile}. Please add it first.${normal}"
        else
            releaseVersion $action $previousVersion $bumpedVersion
        fi
    fi
}

function releaseVersion() {
    export GIT_MERGE_AUTOEDIT_BAK=$GIT_MERGE_AUTOEDIT
    export GIT_MERGE_AUTOEDIT=no

    isNumber='^[0-9]+$'
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

    # Start a release if requested
    if [ $release == true ]
    then
        echo -e ""
        echo -e "> ${green}Starting a release${normal}"
        gitflowErrorCount=$(git flow release start ${currentVersion} 2> >(grep -c "There is an existing release branch"))

        if [[ $gitflowErrorCount =~ $isNumber ]] && [ $gitflowErrorCount -gt 0 ]
        then
            echo -e ""
            echo -e "> ${red}There is an existing release branch, finish or delete that one first.${normal}"
        fi
    fi

    # Bump the version
    composerHasVersion=$(cat composer.json | grep -c "version")
    if [[ $composerHasVersion =~ $isNumber ]] && [ $composerHasVersion -gt 0 ]
    then
        updateComposerVersion $currentVersion
    fi

    git tag -a $currentVersion -m "$currentVersion"

    # Push the changes
    if [ $release == true ]
    then
        git flow release finish ${currentVersion}
        git merge develop
        echo -e ""
        echo -e "> ${green}Pushing changes${normal}"
        git push origin master --tags
        git checkout develop
        git push origin develop --tags
    else
        echo -e ""
        echo -e "> ${green}Pushing changes${normal}"
        git push origin develop --tags
    fi

    echo -e ""
    echo -e "> ${green}We're at version $currentVersion now. All done.${normal}"

    if [ $release == false ]
    then
        echo -e "> This update was not released to the master branch, run ${orange}${versionType}${normal} to release the next update."
    fi


    export GIT_MERGE_AUTOEDIT=$GIT_MERGE_AUTOEDIT_BAK
}

function updateComposerVersion() {
    echo -e "  Also updating composer version"
    echo -e ""

    sed -Ei '.bak' 's/\"version\":[[:space:]]*\"[0-9]*\.?[0-9]*\.?[0-9]*\"/\"version\": \"'$1'\"/' composer.json
    rm composer.json.bak 2> /dev/null

    git add composer.json
    git commit -m "Bump composer version to $currentVersion"
}

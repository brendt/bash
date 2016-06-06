
function release {
    # pull master first so we don't get any merge conflict when pushing
    git checkout master
    git pull origin master
    git checkout develop

    # Check if the first argument is filled in.
    if [ -z ${1+x} ]; then
      VERSION=$(date +'%Y%m%d-%I%M%S')
    else
      VERSION=$1
    fi

    echo $VERSION;


    # start new release with provided version
    git flow release start $VERSION

    # update composer.json with the new version
    if [ -f composer.json ]; then
        sed -ri "s/\"version\": \"(.*)\"/\"version\": \"$VERSION\"/" composer.json
    fi

    # update bower.json with the new version
    if [ -f bower.json ]; then
        sed -ri "s/\"version\": \"(.*)\"/\"version\": \"$VERSION\"/" bower.json
    fi

    git commit -am "bumped version"

    # finish and push release
    export GIT_MERGE_AUTOEDIT_BAK=$GIT_MERGE_AUTOEDIT
    export GIT_MERGE_AUTOEDIT=no
    git flow release finish -m "Released-$VERSION" $VERSION
    git push --all
    export GIT_MERGE_AUTOEDIT=$GIT_MERGE_AUTOEDIT_BAK

    # make sure you are back on develop
    git checkout develop
}

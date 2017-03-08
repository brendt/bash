alias s="open -a /Applications/Sublime\ Text.app/"
alias pstorm="open -a /Applications/PhpStorm.app/"

alias add='git add'
alias st='git status'
alias branch='git branch'
alias co='git checkout'
alias ci='git commit'
alias merge='git merge'
alias tag='git tag'
alias pull='git pull'
alias push='git push'
alias cli='/usr/local/bin/php application/cli.php'
alias lg='tail -f /Applications/MAMP/logs/php_error.log'
alias ride_orm='cli og --debug && cli od --debug'
alias ride_log='tail -f application/data/log/dev.log'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias phpdebug="php -dzend_extension=xdebug.so -d xdebug.auto_trace=ON -d xdebug.trace_output_dir=~/tmp"
alias phpunitdebug="php -dzend_extension=xdebug.so -d xdebug.auto_trace=ON -d xdebug.trace_output_dir=~/tmp vendor/bin/phpunit"

function site {
    cd /s/${1}
}

function str {
	cd /s/${1}
}

function wheather {
    curl http://wttr.in/$1
}

function mgt {
    ssh $1@mgt.server.statik.be
}

function web001 {
    ssh $1@web001.server.statik.be
}

function web002 {
    ssh $1@web002.server.statik.be
}

function tagr {
	if [ -z "${1// }" ];
    then
        echo -e "Usage: tagr <tag>"
    else
		tag=$1

		git checkout develop
		git pull origin develop
		git checkout master
		git pull origin master

		git merge --no-ff develop
		git tag -fa $tag -m $tag
		git push origin :refs/tags/$tag
		git push
		git push --tags

		git checkout develop
		git merge master
		git push
    fi
}
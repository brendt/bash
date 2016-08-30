function git_ps1 {
    if [[ -n $(git status --porcelain 2>/dev/null) ]]
    then
        color=$red
    else
        color=$green
    fi

    branch=$(git branch 2>/dev/null | grep '*' | sed 's/* \(.*\)/\1/')
    tag=$(version)

    if [[ $branch ]]
    then
        if [ $tag == "0.0.0" ]
        then
            echo -e "${color}(${branch}) "
        else
            echo -e "${color}(${branch} @ ${tag}) "
        fi
    fi
}

PS1="${bold_cyan}(\h)${reset} \u ${bold_cyan}\w \$(git_ps1)${reset}"
# PS1="${bold_cyan}(\h)${reset} \u ${bold_cyan}\w\$(get_git_color) \$(__git_ps1)${reset} "

export CLICOLOR=1
export LSCOLORS=cxBxDxCxegedabagacaC

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

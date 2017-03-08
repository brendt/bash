ps1_cyan='\[\033[38;5;14m\]'
ps1_green='\[\033[38;5;2m\]'
ps1_red='\[\033[38;5;1m\]'
ps1_reset='\[$(tput sgr0)\]'

function git_ps1 {
    if [[ -n $(git status --porcelain 2>/dev/null) ]]
    then
        modified=" *"
    else
        modified=""
    fi

    branch=$(git branch 2>/dev/null | grep '*' | sed 's/* \(.*\)/\1/')
    tag=$(version)

    if [[ $branch ]]
    then
        if [ $tag == "0.0.0" ]
        then
            echo "(${branch})${modified} "
        else
            echo "(${branch} @ ${tag})${modified} "
        fi
    fi
}

PS1="${ps1_cyan}\w ${ps1_green}\$(git_ps1)${ps1_reset}"
# PS1="${bold_cyan}(\h)${reset} \u ${bold_cyan}\w\$(get_git_color) \$(__git_ps1)${reset} "

export CLICOLOR=1
# export LSCOLORS=cxBxDxCxegedabagacaC

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

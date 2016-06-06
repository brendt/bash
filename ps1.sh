alias __git_ps1="git branch 2>/dev/null | grep '*' | sed 's/* \(.*\)/(\1)/'"
function get_git_color {
    if [[ -n $(git status --porcelain 2>/dev/null) ]]
    then
        echo -e $red
    else
        echo -e $green
    fi
}
PS1="${bold_cyan}(\h)${reset} \u ${bold_cyan}\w\$(get_git_color) \$(__git_ps1)${reset} "

export CLICOLOR=1
export LSCOLORS=cxBxDxCxegedabagacaC

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

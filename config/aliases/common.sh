alias s='sudo '
alias root='su - root'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

alias rd='rm -rf'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias nowtime='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'

alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '

# --- extracts almost any archive ---
function extract {
    if [ -z "$1" ]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|exe|tar.bz2|tar.gz|tar.xz>"
    else
    if [ -f "$1" ] ; then
        case "$1" in
          *.tar.bz2)   tar xvjf "$1"    ;;
          *.tar.gz)    tar xvzf "$1"    ;;
          *.tar.xz)    tar xvJf "$1"    ;;
          *.lzma)      unlzma "$1"      ;;
          *.bz2)       bunzip2 "$1"     ;;
          *.rar)       unrar x -ad "$1" ;;
          *.gz)        gunzip "$1"      ;;
          *.tar)       tar xvf "$1"     ;;
          *.tbz2)      tar xvjf "$1"    ;;
          *.tgz)       tar xvzf "$1"    ;;
          *.zip)       unzip "$1"       ;;
          *.Z)         uncompress "$1"  ;;
          *.7z)        7z x "$1"        ;;
          *.xz)        unxz "$1"        ;;
          *.exe)       cabextract "$1"  ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}

# --- searches for a file by name (case-insensitive) ---
function ff() {
    if [ -z "$1" ]; then
        echo "Usage: ff <name> [path] [maxdepth]"
    else
    path="."
    [ -n "$2" ] && path="$2"
    maxdepth=""
    [ -n "$3" ] && maxdepth="-maxdepth $3"
    find -L "$path" $maxdepth -type f -iname "*$1*" -print 2>/dev/null
fi
}

# --- searches for a directory by name (case-insensitive) ---
function fd() {
    if [ -z "$1" ]; then
        echo "Usage: fd <name> [path] [maxdepth]"
    else
    path="."
    [ -n "$2" ] && path="$2"
    maxdepth=""
    [ -n "$3" ] && maxdepth="-maxdepth $3"
    find -L "$path" $maxdepth -type d -iname "*$1*" -print 2>/dev/null
fi
}

# --- lists /var/log, or displays the end of logs matching a pattern ---
function logs() {
    if [ -z "$1" ]; then
        ls -lh /var/log
    else
        line=15
        [ -n "$2" ] && line=$2
        for log in $(ls -d -1 /var/log/* 2>/dev/null | grep "$1"); do
            echo "<== $log ==>"
            tail -"$line" "$log"
            echo
        done
    fi
}

# --- searches for a pattern in all .log files in /var/log ---
function logf() {
    if [ "$#" -lt 1 ]; then
        echo "Usage : logf \"pattern\""
        return
    fi
    find -L /var/log -name "*.log" -print0 2>/dev/null | xargs -0 grep --color=always -sn "$1" 2>&- | more
}

# --- searches for a pattern in /etc (standard system config) ---
function conff() {
    if [ "$#" -lt 1 ]; then
        echo "Usage : conff \"pattern\""
        return
    fi
    find -L /etc -name "*.conf" -print0 2>/dev/null | xargs -0 grep --color=always -sn "$1" 2>&- | more
}
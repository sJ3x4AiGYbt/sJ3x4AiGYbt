alias ls='ls --color=auto -1'
alias ll='ls --color=auto -alh'
# ports open 
alias ports='netstat -tulanp'
# package management
alias install='sudo apt-get install'
alias update='sudo apt-get update && sudo apt-get upgrade'
# memory
alias meminfo='free -m -l -t'
# process
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
# cpu
alias cpuinfo='lscpu'
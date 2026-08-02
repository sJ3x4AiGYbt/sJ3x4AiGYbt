alias ls='ls -G -1'
alias ll='ls -G -alh'
# ports open 
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
# package management
alias install='brew install'
alias update='brew update && brew upgrade'
# memory
alias meminfo='vm_stat'
# process
alias psmem='ps aux | sort -nr -k 4'
alias psmem10='ps aux | sort -nr -k 4 | head -10'
alias pscpu='ps aux | sort -nr -k 3'
alias pscpu10='ps aux | sort -nr -k 3 | head -10'
# cpu
alias cpuinfo='sysctl -n machdep.cpu.brand_string'
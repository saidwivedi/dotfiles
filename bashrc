
# ~/.bashrc: Modern bash configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
# Add your custom environment variables here

# ============================================================================
# MODERN BASH OPTIONS & HISTORY
# ============================================================================

# History settings
export HISTCONTROL=ignoreboth:erasedups  # Don't record duplicates or commands starting with space
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="%F %T "
shopt -s histappend                      # Append to history file
shopt -s cmdhist                         # Save multi-line commands in history as single line

# Modern bash options
shopt -s autocd 2>/dev/null              # cd by typing directory name if it's not a command
shopt -s cdspell                         # Auto correct minor spelling errors in cd
shopt -s dirspell 2>/dev/null            # Auto correct directory spelling errors (bash 4.0+)
shopt -s checkwinsize                    # Check window size after each command
shopt -s expand_aliases                  # Expand aliases
shopt -s globstar 2>/dev/null            # Enable ** globbing
shopt -s nocaseglob                      # Case insensitive globbing
shopt -s dotglob                         # Include dotfiles in pathname expansion

# ============================================================================
# MODERN PROMPT WITH GIT INTEGRATION
# ============================================================================

# Git branch function for prompt
git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ ⎇ \1/'
}
git config pull.rebase true

# Modern prompt optimized for light pink background (f6e4e4)
# Using varied dark colors for good contrast
PS1='\[\033[38;5;235m\]╭─\[\033[0m\] \[\033[38;5;22m\]\u\[\033[0m\] \[\033[38;5;235m\]at\[\033[0m\] \[\033[38;5;88m\]\h\[\033[0m\] \[\033[38;5;235m\]in\[\033[0m\] \[\033[38;5;17m\]\w\[\033[0m\]\[\033[38;5;124m\]$(git_branch)\[\033[0m\]
\[\033[38;5;235m\]╰─\[\033[0m\] \[\033[38;5;235m\]❯\[\033[0m\] '

# Set terminal title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS ls color support with LSCOLORS for light pink background
    alias ls='ls -G'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # LSCOLORS for macOS (normal directories, special folders with light backgrounds)
    export LSCOLORS="ExAxAxAxAxegedabagacad"
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Custom LS_COLORS optimized for lightish pink background - normal directories, special folders with light backgrounds and black text
export LS_COLORS='di=1;34:ln=0;36:so=0;35:pi=0;33:ex=0;32:bd=0;33;44:cd=0;33;44:su=0;30;101:sg=0;30;103:tw=0;30;102:ow=0;30;103:*.tar=0;31:*.tgz=0;31:*.arc=0;31:*.arj=0;31:*.taz=0;31:*.lha=0;31:*.lz4=0;31:*.lzh=0;31:*.lzma=0;31:*.tlz=0;31:*.txz=0;31:*.tzo=0;31:*.t7z=0;31:*.zip=0;31:*.z=0;31:*.dz=0;31:*.gz=0;31:*.lrz=0;31:*.lz=0;31:*.lzo=0;31:*.xz=0;31:*.zst=0;31:*.tzst=0;31:*.bz2=0;31:*.bz=0;31:*.tbz=0;31:*.tbz2=0;31:*.tz=0;31:*.deb=0;31:*.rpm=0;31:*.jar=0;31:*.war=0;31:*.ear=0;31:*.sar=0;31:*.rar=0;31:*.alz=0;31:*.ace=0;31:*.zoo=0;31:*.cpio=0;31:*.7z=0;31:*.rz=0;31:*.cab=0;31:*.wim=0;31:*.swm=0;31:*.dwm=0;31:*.esd=0;31:*.jpg=0;35:*.jpeg=0;35:*.mjpg=0;35:*.mjpeg=0;35:*.gif=0;35:*.bmp=0;35:*.pbm=0;35:*.pgm=0;35:*.ppm=0;35:*.tga=0;35:*.xbm=0;35:*.xpm=0;35:*.tif=0;35:*.tiff=0;35:*.png=0;35:*.svg=0;35:*.svgz=0;35:*.mng=0;35:*.pcx=0;35:*.mov=0;35:*.mpg=0;35:*.mpeg=0;35:*.m2v=0;35:*.mkv=0;35:*.webm=0;35:*.ogm=0;35:*.mp4=0;35:*.m4v=0;35:*.mp4v=0;35:*.vob=0;35:*.qt=0;35:*.nuv=0;35:*.wmv=0;35:*.asf=0;35:*.rm=0;35:*.rmvb=0;35:*.flc=0;35:*.avi=0;35:*.fli=0;35:*.flv=0;35:*.gl=0;35:*.dl=0;35:*.xcf=0;35:*.xwd=0;35:*.yuv=0;35:*.cgm=0;35:*.emf=0;35:*.ogv=0;35:*.ogx=0;35:*.aac=0;36:*.au=0;36:*.flac=0;36:*.m4a=0;36:*.mid=0;36:*.midi=0;36:*.mka=0;36:*.mp3=0;36:*.mpc=0;36:*.ogg=0;36:*.ra=0;36:*.wav=0;36:*.oga=0;36:*.opus=0;36:*.spx=0;36:*.xspf=0;36:'


export HF_HOME="~/.cache/huggingface"

# ============================================================================
# CUSTOM ALIASES
# ============================================================================
# Add your custom aliases here

# ============================================================================
# MODERN ALIASES & FUNCTIONS
# ============================================================================

# Enhanced ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -altr'  # Sort by time, newest last
alias lh='ls -alh'   # Human readable sizes

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Modern navigation
alias cd1='cd ..'
alias cd2='cd ../..'
alias cd3='cd ../../..'
alias cd4='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Directory shortcuts
alias d='cd ~/Desktop'
alias dl='cd ~/Downloads'
alias doc='cd ~/Documents'

# Git aliases (modern and clean)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git checkout'
alias gd='git diff'
alias gl='git log --graph --decorate'
alias gll='git log --graph --pretty=format:"%C(yellow)%h%C(reset) - %C(green)(%cr)%C(reset) %s %C(blue)<%an>%C(reset)%C(red)%d%C(reset)"'
alias gs='git status'
alias gsu='git status -uno'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'

# System utilities
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias sb='source ~/.bashrc'
alias vi='vim'

# Network and system info
alias myip='curl -s https://ipinfo.io/ip'
alias ports='netstat -tulanp'

# macOS specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias finder='open -a Finder .'
    alias preview='open -a Preview'
    alias chrome='open -a "Google Chrome"'
    alias code='open -a "Visual Studio Code"'
    alias brewup='brew update && brew upgrade && brew cleanup'
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
fi

# Conda Environment Activations
# Add your conda environment aliases here
# Example: alias myenv="conda activate myenv"

# Modern functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjvf "$1"     ;;
            *.tar.gz)    tar xzvf "$1"     ;;
            *.bz2)       bunzip2 -v "$1"   ;;
            *.rar)       unrar x "$1"      ;;
            *.gz)        gunzip -v "$1"    ;;
            *.tar)       tar xvf "$1"      ;;
            *.tbz2)      tar xjvf "$1"     ;;
            *.tgz)       tar xzvf "$1"     ;;
            *.zip)       unzip -v "$1"     ;;
            *.Z)         uncompress "$1"   ;;  # no verbose option
            *.7z)        7z x "$1"         ;;  # shows progress by default
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function weather() {
    curl -s "wttr.in/$1?format=3"
}

# macOS notification function (replaces Linux notify-send)
function notify() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$2\" with title \"$1\""
    fi
}

# Add your custom functions here







compress_folder() {
    if [ -z "$1" ]; then
        echo "Usage: compress_folder <folder_name>"
        return 1
    fi

    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' does not exist"
        return 1
    fi

    local folder_name="$1"
    local output_file="${folder_name%/}.tar.zst"

    echo "Compressing '$folder_name' to '$output_file'..."
    tar -cvf "$output_file" --use-compress-program="zstd -1 -T0" "$folder_name"

    if [ $? -eq 0 ]; then
        echo "Compression complete!"
        ls -lh "$output_file"
    else
        echo "Compression failed!"
        return 1
    fi
}



# Modern alert function for macOS
alias alert='notify "Command finished" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ============================================================================
# MODERN COMPLETION SYSTEM (Bash)
# ============================================================================

# Enable bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [[ "$OSTYPE" == "darwin"* ]] && [ -f /opt/homebrew/etc/bash_completion ]; then
    . /opt/homebrew/etc/bash_completion
  elif [[ "$OSTYPE" == "darwin"* ]] && [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
  fi
fi

# Case insensitive completion
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set menu-complete-display-prefix on"



# ============================================================================
# MODERN PATH & ENVIRONMENT SETUP
# ============================================================================

# macOS Homebrew setup (if installed)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Add Homebrew to PATH (Apple Silicon and Intel)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Add common macOS development paths
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

    # Python user base (for pip --user installs)
    if command -v python3 &> /dev/null; then
        export PATH="$(python3 -m site --user-base)/bin:$PATH"
    fi
fi

# Modern FZF setup with fallback
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
elif command -v ag &> /dev/null; then
    export FZF_DEFAULT_COMMAND='ag --ignore-dir=*data* --ignore-dir=*result* --ignore-dir=*output* --ignore-dir=*pycache* --hidden -g ""'
else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2> /dev/null'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/etc/profile.d/conda.sh" ]; then
        . "/usr/etc/profile.d/conda.sh"
    else
        export PATH="/usr/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

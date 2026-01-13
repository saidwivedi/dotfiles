# ~/.zshrc: Modern zsh configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# MICROMAMBA ENVIRONMENT SETUP (FIRST PRIORITY)
# ============================================================================

# Micromamba initialization - simplified and more reliable
if command -v micromamba &> /dev/null; then
    # >>> mamba initialize >>>
    export MAMBA_EXE='/usr/bin/micromamba';
    export MAMBA_ROOT_PREFIX="${HOME}/micromamba";
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"  # Fallback
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
fi

# ============================================================================
# MODERN ZSH OPTIONS
# ============================================================================

# History settings
setopt HIST_IGNORE_DUPS         # Don't record duplicate entries
setopt HIST_IGNORE_SPACE        # Don't record entries starting with space
setopt APPEND_HISTORY           # Append to history file
setopt SHARE_HISTORY            # Share history between sessions
setopt HIST_VERIFY              # Show command with history expansion
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicate entries from history
setopt HIST_SAVE_NO_DUPS        # Don't save duplicate entries

# History file settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Modern zsh options
setopt AUTO_CD                  # cd by typing directory name if it's not a command
setopt CORRECT                  # Auto correct mistakes
setopt EXTENDED_GLOB            # Extended globbing
setopt NO_CASE_GLOB            # Case insensitive globbing
setopt RC_EXPAND_PARAM         # Array expension with parameters
setopt NUMERIC_GLOB_SORT       # Sort filenames numerically when it makes sense
setopt NO_BEEP                 # No beep
setopt AUTO_PUSHD              # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS       # Do not store duplicates in the stack
setopt PUSHD_SILENT            # Do not print the directory stack after pushd or popd

# ============================================================================
# MODERN COMPLETION SYSTEM
# ============================================================================

# Enable zsh completion system
autoload -Uz compinit
compinit

# Modern completion styling (optimized for light pink background)
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{0}-- %d --%f'
zstyle ':completion:*:messages' format '%F{0}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{0}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{0}-- %d (errors: %e) --%f'

# Better completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# ============================================================================
# MODERN PROMPT WITH GIT INTEGRATION
# ============================================================================

# Enable git info in prompt
autoload -Uz vcs_info
precmd() {
    vcs_info
    print -Pn "\e]0;%n@%m: %~\a"  # Terminal title
}

# Configure git info (dark colors for light pink background)
zstyle ':vcs_info:git:*' formats ' %F{124}⎇ %b%f'
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

# Modern prompt optimized for light pink background (f6e4e4)
# Using varied dark colors for good contrast on laptop screens
# Include conda environment indicator (only show if not empty)
PS1='${CONDA_DEFAULT_ENV:+%F{28}($CONDA_DEFAULT_ENV)%f }%F{235}╭─%f %F{22}%n%f %F{235}at%f %F{88}%m%f %F{235}in%f %F{17}%~%f${vcs_info_msg_0_}
%F{235}╰─%f %F{235}❯%f '

# Right prompt with time (dark gray for visibility)
RPS1='%F{235}%D{%L:%M:%S}%f'

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
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Directory shortcuts
alias d='cd ~/Desktop'
alias dl='cd ~/Downloads'

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
alias sz='source ~/.zshrc'

# Network and system info
alias myip='curl -s https://ipinfo.io/ip'
alias ports='netstat -tulanp'

# Conda Environments
# Add your conda environment aliases here
# Example: alias myenv='micromamba activate myenv'

# Modern functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

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
            *.Z)         uncompress "$1"   ;;
            *.7z)        7z x "$1"         ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function weather() {
    curl -s "wttr.in/$1?format=3"
}

function gpush() {
  # List tracked files with desired extensions
  tracked_files=$(git ls-files | grep -E '\.(py|sh|ipynb|txt|json|yaml|yml|md)$')
  if [ -z "$tracked_files" ]; then
    echo "🔄 No tracked files with specified extensions to add."
    return
  fi
  # Add only tracked files
  echo "$tracked_files" | xargs git add
  if git diff --cached --quiet; then
    echo "🔄 No changes to commit."
  else
    git commit --amend --no-edit 2>/dev/null || git commit -m "sync: temp changes"
    git push --force
    echo "✅ Code pushed with --amend to keep history clean."
  fi
}

# ============================================================================
# COLOR AND ENVIRONMENT SETUP
# ============================================================================

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Custom LS_COLORS for lightish pink background with black text
export LS_COLORS='di=0;34:ln=0;36:so=0;35:pi=0;33:ex=0;32:bd=0;33;44:cd=0;33;44:su=0;37;41:sg=0;37;43:tw=0;37;42:ow=0;37;43:*.tar=0;31:*.tgz=0;31:*.zip=0;31:*.gz=0;31:*.bz2=0;31:*.jpg=0;35:*.jpeg=0;35:*.gif=0;35:*.png=0;35:*.mp3=0;36:*.wav=0;36:'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export HF_HOME="~/.cache/huggingface"

# Load additional configuration files if they exist
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Load fzf if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

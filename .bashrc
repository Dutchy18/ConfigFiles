source ~/.git-prompt.sh
alias ddd='cvsdiff'
alias gr='grep -rnIi --exclude="tags" --exclude="cscope*" --exclude="*.xml" --exclude="*.html"'
alias gitlog='git log --graph --oneline --decorate'
export DIFFPROG='g -df '

gf ()
{
    local isDiff= remFormat= list= path=
    local typeFlag="-xtype f"
    local exclude="! -iname *.swp ! -iname .#* ! -iname *.rej ! -iname *.orig"
    local exclude_bin="! -iname *.o"
    local usage="Usage: gf [-l] [-a] [-d] expression[:line] [path...]\n
    \n
    Search options:\n
    -a\tMatch all types, including directories\n
    -d\tcvsdiff the selected file - ignored if '-l' is set\n
    -l\tOnly list search results (implicates -a)\n
    \n
    Other options:\n
    --help  Display this message and exit\n"

    # Parse command line arguments
    while [[ "$1" == -* ]] ; do
        case "$1" in
        "-l")          list=1
                       typeFlag=""
                       exclude_bin=""
                       exclude="" ;;
        "-a")          typeFlag=""
                       exclude="" ;;
        "-d")          isDiff=1 ;;
        "--no-format") list=1
            	       remFormat=1 ;;
        "--help")      echo -e $usage
                       return ;;
        *)             echo "gf: invalid option '$1'"
                       echo -e $usage
                       return ;;
        esac

        shift
    done

    if [ -z $1 ]; then
        echo -e $usage
        return
    fi

    if [ ! -z $2 ] && [ -e $2 ] ; then
        path=$2
        echo "Search path: '$path'"
    fi

    local fname=${1%%:*}
    local line=${1:${#fname}}

    local fileArray=($(find $path $typeFlag -iname \*$fname\* $exclude_bin \
        $exclude))
    local aLen=${#fileArray[@]}
    if [ $aLen -eq 0 ]; then
        echo "gf: $fname: No such entry"
        return
    fi

    echo
    for ((i=0; i<$aLen; i++)) do

        # Print unformatted file name
        if [ ! -z $remFormat ]; then
            echo ${fileArray[$i]}
            continue
        fi

        # Mark folder with bold and [d] (removed by "% [d*" when opening gvim)
        if [ -d ${fileArray[$i]} ]; then
            local c="\e[1;36m"
            fileArray[$i]=${fileArray[$i]}" [d]"
        else
            local c="\e[0;36m"
        fi
        
        # Remove './' prefix
        if [ "${fileArray[$i]%%/*}" == "." ]; then
            fileArray[$i]=${fileArray[$i]#*/}
        fi

        echo -en $c
        if [ -z $list ]; then
            echo -ne "[$(($i+1))] " # Add selection count
        fi
        echo ${fileArray[$i]} | sed ''/$fname/s//`printf "$FRed2$fname$c"`/''
       
    done

    # Restore bash color
    echo -e "\e[0m"
    
    if [ ! -z $list ]; then
        return
    fi

    local sel=
    read -p "Select file: " sel
    if [ -z $sel ]; then
        sel=1 # Open first file if no selection
    fi

    # Quit if selection is not a number or not in range
    if [ ! -z "${sel##+([0-9])}" ] || [ $sel -le 0 ] || [ $sel -gt $aLen ]; then
            return
    fi

    if [ ! -z $isDiff ]; then
        cvsdiff "${fileArray[$(($sel-1))]% [d*}"
    else
        g "${fileArray[$(($sel-1))]% [d*}$line"
    fi
}












# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Source global definitions
if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$'

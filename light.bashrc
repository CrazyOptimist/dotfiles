# comment the below line if you do not love vim
export EDITOR=vim

# if not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..="cd .."

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


## git specific
alias gc="git commit -m $1"
alias gca="git commit -a"
alias gs="git status"
alias gaa="git add ."
alias glog="git log"
alias gp="git pull"
alias gd="git diff"

## docker specific
cleanup_docker_containers() {
	docker ps -a | grep Exited | cut -d ' ' -f1 | xargs docker rm
}

cleanup_docker_images() {
	if [ -z "$(docker images | awk '/^<none>/ {print $3}')" ]; then
		echo "You don't have any <none> tagged images."
	else
		docker rmi $(docker images | awk '/^<none>/ {print $3}')
	fi
}

alias dcb="docker-compose build"
alias dcu="docker-compose up $1"
alias dcd="docker-compose down"
alias dcps="docker-compose ps"
alias dclog="docker-compose logs -f"

alias dps="docker ps"
alias dls="docker container ls $1"
alias dils="docker image ls $1"
alias dvls="docker volume ls"
alias dnls="docker network ls"

################################################################################
####################     CRAZYOPTIMIST'S BASH PROMPT      ######################
################################################################################

bash_prompt_command() {
  # How many characters of the $PWD should be kept
  local pwdmaxlen=50

  # Indicate that there has been dir truncation
  local trunc_symbol=".."

  # Store local dir
  local dir=${PWD##*/}

  # Which length to use
  pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))

  NEW_PWD=${PWD/#$HOME/\~}

  local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

  # Generate name
  if [ ${pwdoffset} -gt "0" ]
  then
    NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
    NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
  fi
}


##
## EXTRACT GIT BRANCH NAME IF ANY
##
parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


##
## GENERATE A FORMAT SEQUENCE
##
format_font() {
  # First argument to return format string
  local output=$1

  case $# in
  2)
    eval $output="'\[\033[0;${2}m\]'"
    ;;
  3)
    eval $output="'\[\033[0;${2};${3}m\]'"
    ;;
  4)
    eval $output="'\[\033[0;${2};${3};${4}m\]'"
    ;;
  *)
    eval $output="'\[\033[0m\]'"
    ;;
  esac
}


##
##  FORMAT BASH PROMPT
##
bash_prompt() {

  ##
  ## COLOR CODES
  ##

  ## FONT EFFECT
  local      NONE='0'
  local      BOLD='1'
  local       DIM='2'
  local UNDERLINE='4'
  local     BLINK='5'
  local    INVERT='7'
  local    HIDDEN='8'

  ## COLORS
  local   DEFAULT='9'
  local     BLACK='0'
  local       RED='1'
  local     GREEN='2'
  local    YELLOW='3'
  local      BLUE='4'
  local   MAGENTA='5'
  local      CYAN='6'
  local    L_GRAY='7'
  local    D_GRAY='60'
  local     L_RED='61'
  local   L_GREEN='62'
  local  L_YELLOW='63'
  local    L_BLUE='64'
  local L_MAGENTA='65'
  local    L_CYAN='66'
  local     WHITE='67'

  ## TYPE
  local     RESET='0'
  local    EFFECT='0'
  local     COLOR='30'
  local        BG='40'

  ## 256 COLOR CODES
  local NO_FORMAT="\[\033[0m\]"
  local ORANGE_BOLD="\[\033[1;38;5;208m\]"
  local TOXIC_GREEN_BOLD="\[\033[1;38;5;118m\]"
  local RED_BOLD="\[\033[1;38;5;1m\]"
  local CYAN_BOLD="\[\033[1;38;5;87m\]"
  local BLACK_BOLD="\[\033[1;38;5;0m\]"
  local WHITE_BOLD="\[\033[1;38;5;15m\]"
  local GRAY_BOLD="\[\033[1;90m\]"
  local BLUE_BOLD="\[\033[1;38;5;74m\]"

  ##
  ## Configure Here >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ##

  FONT_COLOR=$GREEN; BACKGROUND=$DEFAULT; TEXTEFFECT=$BOLD
  PROMPT_FORMAT=$CYAN_BOLD

  ## Yes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  ## CONVERT CODES: add offset
  FC=$(($FONT_COLOR+$COLOR))
  BG=$(($BACKGROUND+$BG))
  FE=$(($TEXTEFFECT+$EFFECT))

  ## CALL FORMATING HELPER FUNCTION: effect + font color + BG color
  local TEXT_FORMAT
  format_font TEXT_FORMAT $FE $FC $BG

  # GENERATE PROMPT SECTIONS
  local PROMPT_USER=$"$TEXT_FORMAT\u "
  local PROMPT_HOST=$"$TEXT_FORMAT \h "
  local PROMPT_PWD=$"$TEXT_FORMAT \${NEW_PWD} "
  local PROMPT_INPUT=$"$PROMPT_FORMAT"
  local PROMPT_GIT=$"\$(parse_git_branch)"

  ## BASH PROMPT
  ## Generate PROMPT and remove format from the rest
  PS1="${PROMPT_USER}@${PROMPT_HOST}:${PROMPT_PWD}${PROMPT_GIT} >>>\n$(tput bold)>${PROMPT_INPUT}"

  ## For terminal line coloring, leaving the rest standard
  none="$(tput sgr0)"
  trap 'echo -ne "${none}"' DEBUG
}


##
## MAIN
##

## Bash provides an environment variable called PROMPT_COMMAND.
## The contents of this variable are executed as a regular bash command just before Bash displays a prompt.
## We want it to call our own command to truncate PWD and store it in NEW_PWD
PROMPT_COMMAND=bash_prompt_command

## Call bash_promnt only once, then unset it (not needed any more)
## It will set $PS1 with colors and relative to $NEW_PWD, which gets updated by $PROMPT_COMMAND on behalf of the terminal
bash_prompt
unset bash_prompt

################################################################################
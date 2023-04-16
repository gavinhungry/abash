#!/bin/bash
#
# abash: Useful functions for bash shell scripts
# https://github.com/gavinhungry/abash
#

export _ABASH=1

TMPDIR_BASE=${TMPDIR:-/tmp}

usage() {
  echo -e "\033[1musage\033[0m: $(basename "$0") $*" >&2
  exit 1
}

console_file_path() {
  local FILE_PATH=$1
  if ! ispty && [ -f ${FILE_PATH}.console ]; then
    FILE_PATH=${FILE_PATH}.console
  fi

  echo $FILE_PATH
}

pref() {
  [ "${!1:-0}" -eq 1 ] && return
}

arg() {
  [ $# -ne 1 ] && [ $# -ne 2 ] && return

  local LONG=$(echo "$1" | cut -d: -f1)
  local SHORT=$(echo "$1" | cut -sd: -f2 | head -c 1)
  local SHORT_ARG="${SHORT:-${LONG:0:1}}"
  local DEFAULT=${2:-}

  for (( I=0; I<${BASH_ARGC:-0}; I++ )); do
    if [ $(expr length "$LONG") -ne 1 -a "${BASH_ARGV[$I]}" == "--$LONG" ] ||
       ([[ "${BASH_ARGV[$I]}" =~ ^-[^-] ]] &&
        [[ "${BASH_ARGV[$I]}" =~ ^-.*"$SHORT_ARG" ]]); then
      [ "${BASH_ARGV[$I-1]}" != "${BASH_ARGV[$I]}" ] && echo "${BASH_ARGV[$I-1]}"
      return 0
      break
    fi
  done

  if [ -n "$DEFAULT" ]; then
    echo "$DEFAULT"
    return 0
  fi

  return 1
}

arge() {
  arg "$1" &> /dev/null
}

pfarg() {
  arge $1 && echo "--$1"
}

nfargs() {
  for (( I=$((BASH_ARGC[0] - 1)); I>=0; I-- )); do
    [[ "${BASH_ARGV[$I]}" != -* ]] && echo "${BASH_ARGV[$I]}"
  done
}

fnfarg() {
  NFARGS=($(nfargs))
  echo "${NFARGS[0]}"
}

istty() {
  [ -t 1 ]
}

istty && _ABASH_IS_TTY=1 || _ABASH_IS_TTY=0

_istty() {
  [ $_ABASH_IS_TTY == 1 ]
}

ispty() {
  [[ $(tty) = */pts/[0-9]* ]] && [ $TERM != 'linux' ]
}

tmpdirp() {
  local TMP="${TMPDIR_BASE}/$(basename "$0")-$(whoami)/${1:-tmp}"
  mkdir -m 0700 -p "$TMP"
  echo "$TMP"
}

tmpdir() {
  local TMP="${TMPDIR_BASE}/$(basename "$0")-$(whoami)-$$/${1:-tmp}-${RANDOM}"
  mkdir -m 0700 -p "$TMP"
  echo "$TMP"
}

tmpdirclean() {
  rm -fr "${TMPDIR_BASE}/$(basename "$0")-$(whoami)"{,-$$}
}

quietly() {
  (arge verbose && eval "$*") || eval "$*" &> /dev/null
}

_print() {
  local ATTR=$1; shift
  local FG=$1; shift
  local BG=$1; shift
  local BANNER=$1; shift

  echo -e "\e[${ATTR};${FG};${BG}m${BANNER}\e[0m$*"
}

color() {
  _istty || return

  if [ "$1" == "end" ]; then
    tput sgr0
    return
  fi

  for ARG in "$@"; do
    case $ARG in
      black)          ARG='setaf 0' ;;
      red)            ARG='setaf 1' ;;
      green)          ARG='setaf 2' ;;
      yellow)         ARG='setaf 3' ;;
      blue)           ARG='setaf 4' ;;
      magenta|purple) ARG='setaf 5' ;;
      cyan|lightblue) ARG='setaf 6' ;;
      white)          ARG='setaf 7' ;;
    esac

    tput $ARG
  done
}

msg() {
  local FG=34
  local BG=70

  [ "$1" = "-e" ] && shift && FG=31 # red
  [ "$1" = "-i" ] && shift && FG=32 # green
  [ "$1" = "-w" ] && shift && FG=33 # yellow

  _print 1 $FG $BG "$(basename "$0")" ": $*"
}

inform() {
  msg -i "$* ..."
}

err() {
  msg -e "$*" >&2
}

warn() {
  msg -w "$*" >&2
}

banner() {
  local BANNER=$1; shift
  local ARGS="$*"

  [ ${#*} -ge 1 ] && ARGS=" $ARGS"
  _print 1 1 44 "$BANNER" "$ARGS"
}

bannerline() {
  [ "$1" == -f ] && shift && local PRE=
  local ARGS="$*"
  banner "${PRE-\n} ${ARGS}$(printf '%*s' $((${COLUMNS:-$(tput cols)} - 1 - ${#ARGS})) '')"
}

die() {
  err "$*"
  exit 1
}

checksu() {
  sudo -v || exit 1
  [ $# -gt 0 ] && sudo "$@"
}

sigint() {
  _sigint() {
    die killed
  }

  trap _sigint SIGINT
}

isint() {
  [ "$1" -eq "$1" ] &> /dev/null
}

piduser() {
  ps -o uname= -p "$1"
}

pidofuser() {
  PIDS=()

  for PID in $(pidof -x $2); do
    if [ "$(piduser $PID)" = "$1" ]; then
      PIDS+=($PID)
    fi
  done

  if [ ${#PIDS[@]} -eq 0 ]; then
    return 1
  fi

  echo ${PIDS[@]};
}

pidpid() {
  (isint "$1" && echo "$1") || pidof -s "$1" 2> /dev/null
}

running() {
  pidof -o %PPID -x "$1" > /dev/null
}

nwhich() {
  which -a $1 | grep -v "^$(realpath $0)$" | head -n${2:-1} | tail -n1
}

confirm() {
  local CONFIRM
  read -rp "$* [Y/n] " CONFIRM
  echo

  [ "${CONFIRM,,}" == "y" ] || [ "${CONFIRM,,}" == "yes" ] || [ -z "$CONFIRM" ] || exit 1
}

includes() {
  local -n ARR=$1
  local VAL=$2

  for V in "${ARR[@]}"; do
    [ "$V" = "$VAL" ] && return 0
  done

  return 1
}

split() {
  tr ${1:-,} '\n'
}

xsleep() {
  BASH_LOADABLES_PATH=$(pkg-config bash --variable=loadablesdir)
  enable -f sleep sleep

  sleep $1
}

fmpath() {
  STR="$1"
  shift
  grep -l "^${STR}$" "$@" | head -n1
}

fmpathdir() {
  FILE=$(fmpath "$@")
  [ -n "$FILE" ] && dirname "$FILE"
}

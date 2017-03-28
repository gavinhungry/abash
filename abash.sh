#!/bin/bash
#
# Name: abash.sh
# Auth: Gavin Lloyd <gavinhungry@gmail.com>
# Desc: Small functions for bash shell scripts
#

_ABASH=1

usage() {
  echo -e "\033[1musage\033[0m: $(basename $0) $@"
  exit 1
}

pref() {
  [ ${!1:-0} -eq 1 ] && return
}

arg() {
  [ $# -ne 1 -a $# -ne 2 ] && return

  local LONG=$(echo $1 | cut -d: -f1)
  local SHORT=$(echo $1 | cut -sd: -f2)
  local DEFAULT=$2

  local LONG_ARG="--${LONG}"
  local SHORT_ARG="-${SHORT:-${LONG:0:1}}"

  [ ${#1} -eq 1 ] && COMP="-$1" || COMP="--$1"

  for (( I=0; I<${BASH_ARGC:-0}; I++ )); do
    if [ "${BASH_ARGV[$I]}" == "${LONG_ARG}" -o \
         "${BASH_ARGV[$I]}" == "${SHORT_ARG}" ]; then
      echo ${BASH_ARGV[$I-1]}
      return 0
      break
    fi
  done

  if [ -n "${DEFAULT}" ]; then
    echo ${DEFAULT}
    return 0
  fi

  return 1
}

arge() {
  arg $1 &> /dev/null
}

nfargs() {
  for (( I=$BASH_ARGC-1; I>=0; I-- )); do
    [[ ${BASH_ARGV[$I]} != -* ]] && echo ${BASH_ARGV[$I]}
  done
}

fnfarg() {
  NFARGS=($(nfargs))
  echo ${NFARGS[0]}
}

tmpdir() {
  local TMP="${TMPDIR:-/tmp}/$(basename $0)-$(whoami)-$$/${1:-tmp}-${RANDOM}"

  mkdir -p $TMP
  echo $TMP
}

tmpdirclean() {
  rm -fr "${TMPDIR:-/tmp}/$(basename $0)-$(whoami)-$$"
}

quietly() {
  if arge verbose; then
    eval "$@"
  else
    eval "$@" &> /dev/null
  fi
}

print() {
  local ATTR=$1; shift
  local FG=$1; shift
  local BG=$1; shift
  local BANNER=$1; shift

  echo -e "\e[${ATTR};${FG};${BG}m${BANNER}\e[0m$@"
}

msg() {
  local FG=34
  local BG=70

  [ "$1" = "-e" ] && shift && FG=31 # red
  [ "$1" = "-i" ] && shift && FG=32 # green
  [ "$1" = "-w" ] && shift && FG=33 # yellow

  print 1 $FG $BG "$(basename $0)" ": $@"
}

inform() {
  msg -i "$@ ..."
}

err() {
  msg -e "$@" >&2
}

warn() {
  msg -w "$@" >&2
  continue &> /dev/null
}

banner() {
  print 1 37 44 "$@"
}

bannerline() {
  local ARGS=$@
  banner "${ARGS}$(printf '%*s' $((${COLUMNS:-$(tput cols)} - ${#ARGS})) '')"
}

die() {
  err "$@"
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

pidpid() {
  isint $1 && echo $1 || pidof -s $1 2> /dev/null
}

confirm() {
  read -p "$1 [Y/n] " CONFIRM
  echo

  [ "$CONFIRM" == "Y" -o "$CONFIRM" == "Yes" -o -z "$CONFIRM" ] || exit 1
}

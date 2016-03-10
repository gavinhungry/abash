#!/bin/bash
#
# Name: abash.sh
# Auth: Gavin Lloyd <gavinhungry@gmail.com>
# Desc: Small functions for bash shell scripts
#

usage() {
  echo -e "\033[1musage\033[0m: $(basename $0) $@"
  exit 1
}

pref() {
  [ ${!1:-0} -eq 1 ] && return
}

arg() {
  [ $# -ne 1 -a $# -ne 2 ] && return

  LONG=$(echo $1 | cut -d: -f1)
  SHORT=$(echo $1 | cut -sd: -f2)
  DEFAULT=$2

  LONG_ARG="--${LONG}"
  SHORT_ARG="-${SHORT:-${LONG:0:1}}"

  [ ${#1} -eq 1 ] && COMP="-$1" || COMP="--$1"

  for (( I=0; I<=${BASH_ARGC:-0}; I++ )); do
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

_ABASH=1

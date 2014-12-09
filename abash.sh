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
  [ ${#1} -eq 1 ] && COMP="-$1" || COMP="--$1"

  for (( I=${BASH_ARGC}; I>=0; I-- )); do
    if [ "${BASH_ARGV[$I]}" == "${COMP}" ]; then
      echo ${BASH_ARGV[$I-1]}
      break
    fi
  done
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

#!/bin/bash
#
# Name: abash.sh
# Auth: Gavin Lloyd <gavinhungry@gmail.com>
# Desc: Small functions for bash shell scripts
#

if [ $BASH_SOURCE = $0 ]; then
  echo "$(basename $BASH_SOURCE) must be sourced" >&2
  exit 1
fi

usage() {
  echo -e "\033[1musage\033[0m: $(basename $0) $@"
  exit 1
}

pref() {
  [ ${!1:-0} -eq 1 ] && return
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

  [ "$1" = "-w" ] && shift && FG=33
  [ "$1" = "-e" ] && shift && FG=31

  print 1 $FG $BG "$(basename $0)" ": $@"
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

sigint() {
  _sigint() {
    die killed
  }

  trap _sigint SIGINT
}

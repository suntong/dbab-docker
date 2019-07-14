#!/bin/sh

if [[ "X$1" == "Xsquid" ]]; then
  shift;
  /usr/sbin/squid "$@"
else
  echo Executing "$@"
  exec ${@}
fi

#!/bin/bash

[ -z "$1" ] && exit 1 || nodeNumID=$1
[ -z "$2" ] && exit 2 || type=$2
[ -z "$3" ] && history=10 || history=$3

[ $nodeNumID = "all" ] && nodeNumID=""

case $type in
'write')
  col=2
  ;;
'read')
  col=3
  ;;
'reqs')
  col=4
  ;;
'qlen')
  col=5
  ;;
'bsy')
  col=6
  ;;
*)
  exit 2
  ;;
esac

sum=`fhgfs-ctl --iostat --nodetype=storage --interval=0 --history=${history} ${nodeNumID} 0<&- | \
  awk -F' ' -v n=${col} '{ print \$n }' | \
  egrep '^[0-9]+' | \
  paste -sd+ | \
  bc`

echo "${sum} / ${history}"|bc

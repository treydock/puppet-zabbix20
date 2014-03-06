#!/bin/bash

[ -z "$1" ] && exit 1 || nodeNumID=$1
type=$2
[ -z "$3" ] && history=10 || history=$3

case $type in
'reqs')
  col=2
  ;;
'qlen')
  col=3
  ;;
'bsy')
  col=4
  ;;
*)
  exit 2
  ;;
esac

sum=`fhgfs-ctl --iostat --nodetype=metadata --interval=0 --history=$history $nodeNumID 0<&- | \
  awk -F' ' -v n=$col '{ print \$n }' | \
  egrep '^[0-9]+' | \
  paste -sd+ | \
  bc`

echo "$sum / $history"|bc

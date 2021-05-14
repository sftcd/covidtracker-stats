#!/bin/bash

# set -x

# Grab/rename copies of ie-stats.json files that are not in the current
# data directory

x=${TOP:="$HOME/code/covidtracker-stats"}
x=${DATADIR:="$TOP"}
x=${SRCTOP:="$HOME/data/teks/tek_transparency"}

dirlist=$SRCTOP/202*

for dir in $dirlist
do
    echo $dir
    dstr=`basename $dir`
    ddatestr=${dstr:0:8}
    if [ -f $DATADIR/$ddatestr-*.json ]
    then
        echo "No need to update for $ddatestr"
    else
        if [ -f $dir/ie-stats.json ]
        then
            echo "Would update for $ddatestr"
            cp $dir/ie-stats.json $DATADIR/$dstr.json
        else
            echo "Can't update for $ddatestr - no ie-stats.json there"
        fi
    fi
done

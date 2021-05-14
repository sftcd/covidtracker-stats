#!/bin/bash

# set -x

# script to extract numbers from ie-stats.json files
# you need json_pp and jq installed for this to work
# that makes this slow to run (maybe a 4 mins on my
# dev laptop) but that's ok, speed's not an issue here:-)

x=${TOP:="$HOME/code/covidtracker-stats"}
x=${DATADIR:="$TOP"}

# find our list of files

lof="$DATADIR/202*.json"
# if there's some command line arg, assume that's a set of
# JSON file names
if [[ "$#" != "0" ]]
then
    lof="$*"
fi

# some loop vars
lastcases=0
lastup=0

# vars for our 30 day interval values
dayof30=0
cases30=0
uploads30=0
summary30=""

# overall totals
casesoveall=0
uploadsoverall=0
expectedoverall=0
shortfalloverall=0

# Irish population

# rough approximation - used to validate earlier spreadsheet
# with that figure used
# iepop=4900000
# better esimate, from 
# https://www.cso.ie/en/releasesandpublications/er/pme/populationandmigrationestimatesapril2020/
iepop=4977400 

echo "Daily figures"
echo "Date,Actives,Total Uploads,Cases,Daily Uploads,Expected Uploads,Shortfall"

summary30="Start,End,Cases,Uploads,Expected,Shortfall"

for file in $lof
do
    # our idea of time, based on when we downloaded JSON 
    run=`basename $file .json | sed -e 's/-.*//'`
    run_nice="${run:0:4}-${run:4:2}-${run:6:2}"
    # check if json file parses ok - we do have at least
    # one instance of a truncated file (Dec 19th 2020)
    donothing=`cat $file | json_pp >/dev/null`
    if [[ "$?" != "0" ]]
    then
        echo "Skipping $file as json_pp doesn't like it" >&2
        continue
    fi
    # HSE's idea of time, based on when file generated, not used 
    ga=`cat $file | json_pp | jq .generatedAt | sed -e 's/"//g'`
    # active users - always 13000000 so far
    au=`cat $file | json_pp | jq .activeUsers`
    # number of installs, does vary but not used
    ins=`cat $file | json_pp | jq .installs[-1][1]`
    # number of TEK uploads since time began
    up=`cat $file | json_pp | jq .uploads`
    # number of cases declared by HSE for this day
    cases=`cat $file | json_pp | jq .chart[-1][1]`

    # things we calculate from the above

    # TEK uploads this day
    dayup=$((up-lastup))
    # remember those for tomorrow's day
    lastup=$up
    lastcases=$cases

    # multiplier to get around bash's lack of floating point;-)
    mult=10000000

    # percent of population who installed - not used
    perinst=$((100*ins/iepop))
    # pecent of population who are active users
    peract=$((mult*100*au/iepop))
    # expected number of uploads for today
    expup=$((peract*cases/(100*mult)))
   
    # shortfall calculation as per paper
    cpop=$(((mult*cases)/iepop))
    hc=$(((mult*dayup)/au))
    sf=$(((100*(cpop-hc)/cpop)))

    # accumulate overalls, except for very 1st day
    if [[ "$dayof30" != "0" ]]
    then
        casesoverall=$((casesoverall+cases))
        uploadsoverall=$((uploadsoverall+dayup))
    fi

    # output to csv, except for versy 1st day
    if [[ "$dayof30" != "0" ]]
    then
        echo $run_nice,$au,$up,$cases,$dayup,$expup,$sf
    fi

    # do 30 day at at a time intervals, but we start counting
    # at 1 because there initial daily-upload figure isn't a
    # real value (as we'd no "yesterday" to subtract then)
    if [[ "$((dayof30%30))" == "1" ]]
    then
        if [[ "$dayof30" == "1" ]]
        then
            # special case - throw away very 1st day
            cases30=0
            uploads30=0
            verystart=$run_nice
        fi
        start30="$run_nice"
    fi
    cases30=$((cases30+cases))
    uploads30=$((uploads30+dayup))
    if [[ "$((dayof30%30))" == "0" ]]
    then
        if [[ "$dayof30" != "0" ]]
        then
            end30="$run_nice"
            exp30=$((peract*cases30/(100*mult)))
            cpop30=$(((mult*cases30)/iepop))
            hc30=$(((mult*uploads30)/au))
            sf30=$(((100*(cpop30-hc30)/cpop30)))
            # output line...
            summary30="$summary30\n$start30,$end30,$cases30,$uploads30,$exp30,$sf30"
            # re-init vars
            cases30=0
            uploads30=0
        fi
    fi
    dayof30=$((dayof30+1))

    lastday=$run_nice

done

echo "30 Day interval summary"
echo -e "$summary30"

expectedoverall=$((peract*casesoverall/(100*mult)))
cpopoverall=$(((mult*casesoverall)/iepop))
hcoverall=$(((mult*uploadsoverall)/au))
sfoverall=$(((100*(cpopoverall-hcoverall)/cpopoverall)))

echo "Overall"
echo "$verystart,$lastday,$casesoverall,$uploadsoverall,$expectedoverall,$sfoverall"

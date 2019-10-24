#!/bin/bash
# some variables...
chr="-->"
run_="1" # running count set to start value
re_='^[0-9]+$'

# exit if input(s) not given...
if [[ -z $1 ]] || [[ -z $2 ]] 
then echo "Needed One or more Input(s). Consult the help..." && tail -13 $0 && exit 1
else :
fi

# exit if no number input is given...
if ! [[ $1 =~ $re_ ]] 2> /dev/null 
then echo "Error: No seconds(number) is given or Format is wrong. Consult the help..." && tail -13 $0 && exit 1
else :
fi

# exit if no file to prcess...
if ! [[ -f "$2" ]]
then echo "Error: No File to process. Consult the help..." && tail -13 $0 && exit 1
else tot_=$(cat "$2"|wc -l) # total number of lines of the given file
fi

# making directory if not there...
if [ -d "done" ]
then :
else mkdir "done"
fi

# removing the given file if its there already...
rm -f "done/$2" 2> /dev/null

# fetch the timing part, convert to secs, add/sub secs, convert back to hh:mm:ss & save it.
cat "$2"| while read l
do
if [[ $(echo $l | grep -c -- "$chr") -ne 0 ]]
then 
# convert to plain seconds format...
one_=$(echo $l|awk -F"-->" '{print $1}'|awk -F':|,' '{ print ($1 * 3600) + ($2 * 60) + $3 }')
one_s=$(echo $l|awk -F"-->" '{print $1}'|awk -F':|,' '{print $4}')
two_=$(echo $l|awk -F"-->" '{print $2}'|awk -F':|,' '{ print ($1 * 3600) + ($2 * 60) + $3 }')
two_s=$(echo $l|awk -F"-->" '{print $2}'|awk -F':|,' '{print $4}')
# adding/subtracting seconds...
if [[ $3 == 'a' ]]
then one_=$((one_-$1)) && two_=$((two_-$1))
else one_=$((one_+$1)) && two_=$((two_+$1))
fi
# convert to hh:mm:ss format from seconds...
printf "`date -d@$one_ -u +%H:%M:%S,$one_s` `echo "-->"` `date -d@$two_ -u +%H:%M:%S,$two_s`\n" >> "done/$2"
else echo $l >> "done/$2"
fi
# printing the progress...
printf "`echo "[$run_/$tot_]"` `echo -ne $(for i in $(seq 1 $((100*run_/tot_)) );do echo -n "#";done)` `echo [$((100*run_/tot_))]'\r'`"
run_=$((run_+1))
done
echo -ne '\n' # just to keep the progress output line undisturbed...
echo Completed...
# =======HELP===========
# This script will do timing correction (delay/advance sync in seconds) to the given subtitle file & create a new file under 
# 'done' folder (it'll be created if it's not there). Every line of verbal quotes in the subtitle file will be delayed or 
# advanced by the given seconds. 
# [Note: This script uses UNIX Epoch time for seconds manipulation. So advancing time '00:00' may produce error o/p. Also Please note 
# that you can't do any milli seconds correction with this script and this script is tested with only .srt formats. Oops! sorry...]
# Format... 
# ./sub_sync.sh <time_secs> <subtitle_file.srt> <|a> # time_secs = how many seconds you would want; |a = if you want delay, 
#	no need to use this option as its optional. but if you want to advance the time, just put 'a' (w/o quotes)
# e.g.
# ./sub_sync.sh 5 file.srt 	# delay by 5 seconds
# ./sub_sync.sh 3 file.srt a 	# advance by 3 seconds
# written by -kamalakannan [Dec'18]

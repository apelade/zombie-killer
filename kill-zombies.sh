#!/bin/bash
# MOOC autograder zombie sweeper.
#
# Kill processes that match command including arguments (unlike pkill) and exceed max run time.
# Run every 17 minutes with 'watch -n 1020 kill_zombies.sh'
# Don't run it all the time in case it goes rogue.
# Originally a one-liner: watch -n 1400 kill $(ps ao etime,pid,args | awk ' /[r]uby .\/grade4/ { gsub(/[:-]/,""); pid=($1 >= 700 ? $2 : ""); if (pid != "") {print pid; d=strftime("[%Y-%m-%d %H:%M:%S]",systime()); print d, pid >> "killing_zombie_process_list.log"; }} ')


# Kill processes older than seven minutes.
TIMEOUT=700

# Kill processes that command args match this.
REGEX='[r]uby .\/grade4'


# Keep a log so you know if it's working.
LOGFILE="killing_zombie_log.txt"


# Test with data.
#ZOMBIES=$(cat test-data.txt | awk '
# The real thing.
ZOMBIES=$(ps ao etime,pid,args | awk '
	# match process command
	$0 ~ regex {
                 # remove punctuation for compare vs timeout
		 gsub(/[:-]/,"");
                 elapsed=$1;
                 pid=$2;
                 if (elapsed >= timeout ) {
                        # yield pid for kill list
                 	print pid;
		        # log it
			timestamp=strftime("[%Y-%m-%d %H:%M:%S]",systime());
			print timestamp, elapsed, pid >> logfile;
		 }
	}
' logfile=$LOGFILE timeout=$TIMEOUT regex="$REGEX")

# Be aware of how your application traps shutdown signals.
kill $ZOMBIES
sleep 1
kill -9 $ZOMBIES

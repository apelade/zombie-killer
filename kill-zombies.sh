#!/bin/bash
# MOOC autograder zombie sweeper.
#
# Kill processes that match command including arguments and exceed max run time.
# Run every 17 minutes like 'watch -n 1020 kill_zombies.sh'
# Set constants below.
# Originally a one-liner: watch -n 1400 kill $(ps ao etime,pid,args | awk ' /[r]uby .\/grade4/ { gsub(/[:-]/,""); pid=($1 >= 700 ? $2 : ""); if (pid != "") {print pid; d=strftime("[%Y-%m-%d %H:%M:%S]",systime()); print d, pid >> "killing_zombie_process_list.log"; }} ')

REGEX='[r]uby .\/grade4'
# Time is in minutes:seconds. 700 is 7 minutes.
TIMEOUT=700
LOGFILE='killing_zombie_log.txt'
GENTLE_KILL_SIGNAL='TERM'

# Run test data
#ZOMBIES=$(cat test-data.txt | \

# Find all matching old processes.
ZOMBIES=$(ps ao etime,pid,args | \
awk '
	# match process command
	$0 ~ regex {
                 # remove punctuation from elapsed
		 gsub(/[:-]/,"");
                 elapsed=$1;
                 pid=$2;
                 if ( elapsed >= timeout ) {
                        # yield pid to kill list
                 	print pid;
		        # and log
			timestamp=strftime("[%Y-%m-%d %H:%M:%S]",systime());
			print timestamp, elapsed, pid >> logfile;
		 }
	}
# inject bash varibles to awk
' logfile=$LOGFILE timeout=$TIMEOUT regex="$REGEX"
)

function log {
  message = $1
  touch $LOGFILE;
  echo $message >> $LOGFILE;
}

function running {
  pid=$1
  if [ -n "$(ps --no-headers -p $pid -o etime,pid,args)" ]
  then true;
  else false;
  fi
}

# Kill with increasing insistence.
for pid in $ZOMBIES
do
  if ! running $pid;then
    log "Attempt to kill process not found: $pid"
  else
    log "kill $pid"
    kill -s $GENTLE_KILL_SIGNAL $pid;
    sleep 5;
    if running $pid;then
      log "Process survived signal TERM: $pid Escalate.";
      sleep 15;
      kill -s KILL $pid;
      sleep 5;
      if running $pid;then
        log "Process cannot be killed: $pid";
      fi
    fi
  fi
done

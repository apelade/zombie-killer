#!/bin/bash
# MOOC autograder zombie sweeper.
#
# Kill processes that match command including arguments and exceed max run time.
# Run every 17 minutes like 'watch -n 1020 kill_zombies.sh'
# Set constants below.
# Originally a one-liner: watch -n 1400 kill $(ps ao etime,pid,args | awk ' /[r]uby .\/grade4/ { gsub(/[:-]/,""); pid=($1 >= 700 ? $2 : ""); if (pid != "") {print pid; d=strftime("[%Y-%m-%d %H:%M:%S]",systime()); print d, pid >> "killing_zombie_process_list.log"; }} ')

# Target processes that command args match this.
REGEX='[r]uby .\/grade4'

# Target processes older than seven minutes.
TIMEOUT=700

# Keep a log so you know if it's working.
LOGFILE="killing_zombie_log.txt"

# Varies by application. We use TERM.
# INT is equivalent of Ctrl+c for some processes.
GENTLE_KILL_SIGNAL="TERM"

# Use test data.
#ZOMBIES=$(cat test-data.txt | \
# The real thing. Stat :sh may be useful?.
ZOMBIES=$(ps ao etime,pid,args | \
awk '
	# Match the process command,
	$0 ~ regex {
                 # remove punctuation for compare vs timeout,
		 gsub(/[:-]/,"");
                 elapsed=$1;
                 pid=$2;
                 if ( elapsed >= timeout ) {
                        # yield pid for kill list,
                 	print pid;
		        # and log it.
			timestamp=strftime("[%Y-%m-%d %H:%M:%S]",systime());
			print timestamp, elapsed, pid >> logfile;
		 }
	}
# Inject bash varibles into awk.
' logfile=$LOGFILE timeout=$TIMEOUT regex="$REGEX"
)

#todo DRY log with awk script?
function log {
  touch $LOGFILE;
  echo $1 >> $LOGFILE;
}

function running {
  pid=$1
  if [ -n "$(ps --no-headers -p $pid -o etime,pid,args)" ]
  then true;
  else false;
  fi
}

# Kill process ids with increasing insistence.
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

zombie-killer
=============
script to terminate zombie processes by staleness and match on command arguments

- MOOC autograder zombie sweeper spring 2014
- Kill processes that match command including arguments (unlike pkill) and exceed max run time.
- Run every 17 minutes with 'watch -n 1020 kill_zombies.sh'
- Don't run it all the time in case it goes rogue.
- Originally a one-liner:
```
watch -n 1400 kill $(ps ao etime,pid,args | awk ' /[r]uby .\/grade4/ { gsub(/[:-]/,""); pid=($1 >= 700 ? $2 : ""); if (pid != "") {print pid; d=strftime("[%Y-%m-%d %H:%M:%S]",systime()); print d, pid >> "killing_zombie_process_list.log"; }} ')
```



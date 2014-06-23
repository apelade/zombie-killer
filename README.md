zombie-killer
=============
#### Kill processes that (exceed max run time) AND (match command INCLUDING arguments) ####

- Edit kill-zombies.sh to change timeout and regex.
- Run in a screen or tmux like: 'watch -n 1020 kill_zombies.sh'
- Test by uncommenting the input from test-data.txt.
- Results are logged to file.
- Getting awk: warning: escape sequence \`\/' treated as plain \`/'
- Originally a one-liner:
```
watch -n 1400 kill $(ps ao etime,pid,args | awk ' /[r]uby .\/grade4/ { gsub(/[:-]/,""); pid=($1 >= 700 ? $2 : ""); if (pid != "") {print pid; d=strftime("[%Y-%m-%d %H:%M:%S]",systime()); print d, pid >> "killing_zombie_process_list.log"; }} ')
```



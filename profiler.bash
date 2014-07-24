# Bash Trace function ``shTrace'' ==  Elap-bash V3:
# After trying to use /proc/timer_list and some tests and comparission
# there is a BASH profiler, designed under Bash v4.2.37, for having a
# minimal footprint. This method use only two forks and
# do render trace at end of whole job.

shTrace() {
    shlfle=$(mktemp /dev/shm/recomp-XXXXXXXXXX.log||exit 1)
    exec 29>$shlfle
    rm $shlfle
    exec 28</dev/fd/29
    shtfle=$(mktemp /dev/shm/recomp-XXXXXXXXXX.tim||exit 1)
    exec 30>$shtfle
    rm $shtfle
    exec 27</dev/fd/30
    exec 31> >(
        tee /dev/fd/29 |
            sed -u 's/.*/now/' |
            date -f - +%s%N >&30
    )
    trap printLog 0 1 2 3 6 9 15
    BASH_XTRACEFD=31
    set -x
}
printLog() {
    set +x
    local last= tim= crt= tot=0 pc=0000000000 pt=0000000000 \
        fmtstr="%15.9f %15.9f  %s\n" count=100
    # Delay upto 10 second if there are unfinished childs
    while [ $(jobs -p|wc -l) -gt 0 ] && ((count--)) ;do
        sleep .1
    done
    # Print unfinished jobs if any
    jobs
    # Close trace FD
    exec 31>&-
    sync
    # Whipe 1st null line.
    read -u 27 last
    while read -u 27 tim ;do
        read -u 28 line
        crt=$[ tim-last ]
        ((tot+=crt))
        pc=0000000000$crt pt=0000000000$tot
        printf "$fmtstr" ${pc:0:${#pc}-9}.${pc:${#pc}-9} \
            ${pt:0:${#pt}-9}.${pt:${#pt}-9} "$line"
        ((last=tim))
    done 
    printf "$fmtstr" ${pt:0:${#pt}-9}.${pt:${#pt}-9}{,} Total
    exec 27>&- 28>&- 29>&- 30>&- 31>&-
    exit
}
shTrace

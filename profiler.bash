# Bash Trace function ``shTrace'' ==  Elap-bash V3:
# After trying to use /proc/timer_list and some tests and comparission
# there is a BASH profiler, designed under Bash v4.2.37, for having a
# minimal footprint. This method use only two forks and
# do render trace at end of whole job.

_shUsage() {
    cat <<-eousage
	Usage: $0 [-h] [-w integer] [-p integer]
	    -h show this help.
	    -w max wait time in seconds for all childs process to finish
	    -p precision: length of time's fractional part
	eousage
}
_shTrace() {
    local OPTIND
    while getopts "hw:p:" _shCrt;do
	if [ "$_shCrt" = "h" ] ;then
	    _shUsage
	    exit 0
	fi; done;
    local _shLogFile=$(mktemp /dev/shm/shProfiler-XXXXXXXXXX.log||exit 1)
    exec 29>$_shLogFile
    rm $_shLogFile
    exec 28</dev/fd/29
    local _shTimeFile=$(mktemp /dev/shm/shProfiler-XXXXXXXXXX.tim||exit 1)
    exec 30>$_shTimeFile
    rm $_shTimeFile
    exec 27</dev/fd/30
    exec 31> >(
	tee /dev/fd/29 |
	    sed -u 's/.*/now/' |
	    date -f - +%s%N >&30
    )
    trap "_printLog $*" 0 1 2 3 6 9 15
    BASH_XTRACEFD=31
    set -x
}
_printLog() {
    set +x
    local _shLast= _shTim= _shCrt= _shTot=0 _shC=0000000000 _shT=0000000000 \
	_shCnt=100 _shFmtStr= _shLogLine= _shNumLen=9 _shFracLen=5
    while getopts "hw:p:" _shCrt;do case $_shCrt in
	    w ) _shCnt=$[10*OPTARG] ;;
	    p ) _shFracLen=$[OPTARG];;
	    * ) printf >&2 "Error: %s: Argument '%s' unknown.\n" $0 $_shCrt;;
	esac; done;
    # Delay upto 10 second if there are unfinished childs
    while [ $(jobs -p|wc -l) -gt 0 ] && ((_shCnt--)) ;do
        sleep .1
    done
    # Print unfinished jobs if any
    jobs
    # Close trace FD
    exec 31>&-
    sync
    # Whipe 1st null line, take base time.
    read -u 27 _shLast
    printf -v _shNumLen "%(%s)T-%s\n" -1 ${_shLast:0:${#_shLast}-9}
    _shNumLen=$[_shNumLen]
    _shNumLen=$[1+${#_shNumLen}+_shFracLen]
    printf -v _shFmtStr "%%%d.%df %%%d.%df  %%s\\n" \
	$_shNumLen $_shFracLen $_shNumLen $_shFracLen
    while read -u 27 _shTim ;do
	read -u 28 _shLogLine
        _shCrt=$[ _shTim-_shLast ]
        ((_shTot+=_shCrt))
    	_shC=0000000000$_shCrt _shT=0000000000$_shTot
        printf "$_shFmtStr" ${_shC:0:${#_shC}-9}.${_shC:${#_shC}-9} \
    	    ${_shT:0:${#_shT}-9}.${_shT:${#_shT}-9} "$_shLogLine"
        ((_shLast=_shTim))
    done 
    printf "$_shFmtStr" ${_shT:0:${#_shT}-9}.${_shT:${#_shT}-9}{,} Total
    exec 27>&- 28>&- 29>&- 30>&- 31>&-
    exit
}
_shTrace $@

bashProfiler
============

Bash profiler function ``shTrace'' (was  Elap-bash V3):
After initialy try to use /proc/timer_list and some
tests and comparission, (you may find them there:

http://stackoverflow.com/a/20855353/1765658

I wrote this BASH profiler, designed under Bash v4.2.37,
for having a minimal footprint and finest precision.

This method use only two forks and do render trace at end of whole job.

Usage:
------


Simply add `souce bashProfiler` at begin of your script,
or run:
    `bash -c "source bashProfiler;source myScriptToProfile"`

bashProfiler
============

== We're Using GitHub Under Protest ==

This project is currently hosted on GitHub.  This is not ideal; GitHub is a
proprietary, trade-secret system that is not Free and Open Souce Software
(FOSS).  We are deeply concerned about using a proprietary system like GitHub
to develop our FOSS project.  For further version of this projects, have a look
[My web bazzar ](https://f-hauri.ch/vrac/?C=M;O=D) where most of my ideas are
still published until I made a choice for further shares...

We urge you to read about the [Give up GitHub](https://GiveUpGitHub.org)
campaign from [the Software Freedom Conservancy](https://sfconservancy.org) to
understand some of the reasons why GitHub is not a good place to host FOSS
projects.

If you are a contributor who personally has already quit using GitHub, please
[send mail to gitproj@f-hauri.ch](mailto://gitproj@f-hauri.ch) for any comment
or contributions without using GitHub directly.

Any use of this project's code by GitHub Copilot, past or present, is done
without our permission.  We do not consent to GitHub's use of this project's
code in Copilot.

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/img/GiveUpGitHub.png)

Copying:
--------

As bash, this stuff is licensed under GNU GPL v3.0 or later.

Introduction:
-------------

Bash profiler function ``shTrace'' (was  Elap-bash V3):
After initialy try to use /proc/timer_list and some
tests and comparission, (you may find them there:

http://stackoverflow.com/a/20855353/1765658

I wrote this BASH profiler, designed under Bash v4.2.37,
for having a minimal footprint and finest precision.

This method use only two forks and do render trace at end of whole job.

Usage:
------

    bash [-h] [-w integer ] [-p integer ]
      -h show this help.
      -w max wait time in seconds for childs process to finish
      -p precision: length of time's fractional part

Simply add `souce profiler.bash` at begin of your script,
or run:

    bash -c "source profiler.bash;source myScriptToProfile"

Bug
---

Childs are not profiled, nor sumarized. The only argument `-w` let you precise
a max wait time until all childs finish (my loop could maybe be replaced by
`wait` builtin, but it's not well tested.).

Sample/test run
---------------

    bash -c ". profiler.bash;echo hi there;sleep 1&sleep .2;echo done"
    hi there
    done
    0.00007 0.00007  + echo hi there
    0.00001 0.00008  + sleep .2
    0.19910 0.19917  + sleep 1
    0.00004 0.19922  + echo done
    0.00002 0.19924  + _printLog
    0.19924 0.19924  Total

    bash -c ". profiler.bash -p 2;echo hi there;sleep 1&sleep .2;echo done"
    hi there
    done
    0.00 0.00  + echo hi there
    0.00 0.00  + sleep .2
    0.20 0.20  + sleep 1
    0.00 0.20  + echo done
    0.00 0.20  + _printLog -p 2
    0.20 0.20  Total

    bash -c ". profiler.bash -w 1 -p 2;echo hi there;sleep 2 & sleep .2;echo done"
    hi there
    done
    [1]+  Running                 sleep 2 &
    profiler.bash: line 59: ${#_shLast}-9: substring expression < 0

# Distilled-Exawatcher-VmStat
Tool to statistically analyze Exawatcher VmStat data files to help with CPU capacity planning.

## Usage
    usage: exawatcher_CPU.summary.sh [-s] [-c N] [-d DATE] fileglob
      -s  prints vmstat details when CPU is saturated (idle = 0)
      -c  set CPU core count (default 48 CPU cores) (This is when running analysis on a workstation to match server details)
      -d  set date string easily, e.g.
          now, yesterday, -1week (lastweek), etc.

     fileglob (uses bash extended glob feature) of pattern match
     to select input files. If DATE isn't specified, fileglob is required.
     E.G., all the files for the last 24 hours:
       exawatcher_CPU.summary.sh -d yesterday
     all the files for June 2024:
       exawatcher_CPU.summary.sh 2024_06
     files for the week of May 19-21:
       exawatcher_CPU.summary.sh 2024_06_?(19|20|21)
       would match Exawatcher files:
        2024_06_19_*VmstatExaWatcher_*.dat.bz2
        2024_06_20_*VmstatExaWatcher_*.dat.bz2
        2024_06_21_*VmstatExaWatcher_*.dat.bz2
        2024_06_21_*VmstatExaWatcher_*.dat

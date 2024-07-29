# Distilled-Exawatcher-VmStat
Tool to statistically analyze Exawatcher VmStat data files to help with CPU capacity planning.
Provides Mode, Median, Max and Min CPU analysis.
Can also provide CPU saturation events (when CPU idle time is reported as zero).

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

## Examples

### Process all files for 19-June-2024 between 10:00:00 - 10:59:59

     … Vmstat.ExaWatcher] > bash ~/proj/exawatcher_CPU.summary.sh 2024_06_19_10
    -> 2024_06_19_10_15_40_VmstatExaWatcher_srvr1.joe.org.dat.bz2:
    # Starting Time:	06/19/2024 10:15:40
       Mode CPU RQ:  59.0
     Median CPU RQ:  61.0
        Avg CPU RQ:  61.91           Avg %CPU: 94.32 us 4.42 sy 1.26 id
    Max/Min CPU RQ:  99 / 51     %CPU Max/Min: 97 / 85 us 12 / 2 sy 3 / 0 id
    -> 2024_06_19_10_45_49_VmstatExaWatcher_srvr1.joe.org.dat.bz2:
    # Starting Time:	06/19/2024 10:45:49
       Mode CPU RQ:  56.0
     Median CPU RQ:  58.0
        Avg CPU RQ:  59.17           Avg %CPU: 94.97 us 3.77 sy 1.20 id
    Max/Min CPU RQ: 105 / 49     %CPU Max/Min: 97 / 88 us 10 / 2 sy 2 / 0 id

    VmstatExaWatcher Data Set Summary of 2 input files:
        Start Time: 06/19/2024 10:15:40  <-->   End Time: 06/19/2024 10:45:49
       Mode CPU RQ: none
     Median CPU RQ: 59.50 ~ 123.96% of 48 HW CPU cores
        Avg CPU RQ: 60.54 ~ 126.12% of 48 HW CPU cores
          Avg %CPU: 94.64 us 4.09 sy 1.23 id
    Max/Min CPU RQ: 105 / 49 ~ 218.75% / 102.08% of 48 HW CPU cores
      %CPU Max/Min:  97 / 85 us  12 /  2 sy   3 /  0 id

### Process all files for 19-June-2024

    ...
    -> 2024_06_19_21_19_26_VmstatExaWatcher_srvr1.joe.org.dat.bz2:
    # Starting Time:	06/19/2024 21:19:26
       Mode CPU RQ:  74.0
     Median CPU RQ:  74.0
        Avg CPU RQ:  75.57           Avg %CPU: 91.42 us 7.38 sy 1.13 id
    Max/Min CPU RQ: 115 / 54     %CPU Max/Min: 95 / 84 us 14 / 4 sy 2 / 0 id
    -> 2024_06_19_21_49_36_VmstatExaWatcher_srvr1.joe.org.dat.bz2:
    # Starting Time:	06/19/2024 21:49:36
       Mode CPU RQ:  65.0
     Median CPU RQ:  66.0
        Avg CPU RQ:  66.86           Avg %CPU: 93.36 us 5.37 sy 1.21 id
    Max/Min CPU RQ:  95 / 55     %CPU Max/Min: 96 / 88 us 10 / 3 sy 2 / 1 id
    -> 2024_06_19_22_19_47_VmstatExaWatcher_srvr1.joe.org.dat:
    # Starting Time:	06/19/2024 22:19:47
       Mode CPU RQ:  74.0
     Median CPU RQ:  71.0
        Avg CPU RQ:  70.29           Avg %CPU: 92.37 us 5.85 sy 1.73 id
    Max/Min CPU RQ:  88 / 46     %CPU Max/Min: 95 / 81 us 11 / 4 sy 8 / 0 id

    VmstatExaWatcher Data Set Summary of 45 input files:
        Start Time: 06/19/2024 00:21:15  <-->   End Time: 06/19/2024 22:19:47
       Mode CPU RQ: 60.00 ~ 125.00% of 48 HW CPU cores
     Median CPU RQ: 62.00 ~ 129.17% of 48 HW CPU cores
        Avg CPU RQ: 65.64 ~ 136.75% of 48 HW CPU cores
          Avg %CPU: 93.40 us 5.31 sy 1.27 id
    Max/Min CPU RQ: 142 / 21 ~ 295.83% / 43.75% of 48 HW CPU cores
      %CPU Max/Min:  98 / 43 us  21 /  2 sy  51 /  0 id

_This analysis indicates that the server was overloaded over the month of June!_   

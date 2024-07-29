#!/bin/bash

## Joe Nyilas, crafted this.
## Oracle Advanced Consulting
## A NyiLabs project and unpublished work.
## Prototyped and conceptualized 13-June-2024

#
# $Id: exawatcher_CPU.summary.sh,v 1.5 2024/07/29 19:35:57 jnyilas Exp $
#

# Synopsis
# Tool to summarize Exawatcher vmstat data files (from the archive location) looking an particular at cpu run queue and CPU idle.
# argv1 is glob (uses bash extended glob feature) of pattern match of files to process.
# E.G.,
# all the files for June 2024:
# ./zdlra_CPU.summary.sh 2024_06
#
# files for the week of May 19:
# /zdlra_CPU.summary.sh 2024_05_?(19|20|21|22|23|24)
#   Tally: Avg CPU run_queue: 63.23   Avg  CPU %Idle: 2.59
#   Tally: Max:Min CPU run_queue: 228 : 0  Min:Max CPU %Idle: 0 : 100

myawk()
{
	#/^[0-9][0-9]*/ {i+=$1; j+=$15; c+=1; print $1 ","$15}
	awk 'BEGIN {i=0; id=0; us=0; sy=0; c=0;rq_max=0; rq_min=1024; idl_max=0; idl_min=100; us_min=100; us_max=0
                    sy_min=100; sy_max=0}
	/^# Starting Time:/ {print}
	/^[0-9][0-9]*/ {if (NF==17) { #this for uncompressed (without extra time field)
		i+=$1; id+=$15; sy+=$14; us+=$13; rq_array[c]=$1; c++
		if ($1>rq_max) rq_max=$1 
		if ($1<rq_min) rq_min=$1
		if ($15>idl_max) idl_max=$15
		if ($15<idl_min) idl_min=$15
                if ($13>us_max) us_max=$13
                if ($13<us_min) us_min=$13 
                if ($14>sy_max) sy_max=$14
                if ($14<sy_min) sy_min=$14 
		if ("'"${sat}"'"==1 && $15==0) print
		}
	else {if (NF==18) { #this for compressed (with time field)
		i+=$2; id+=$16; sy+=$15; us+=$14; rq_array[c]=$2; c++
                if ($2>rq_max) rq_max=$2 
                if ($2<rq_min) rq_min=$2
                if ($16>idl_max) idl_max=$16
                if ($16<idl_min) idl_min=$16 
                if ($14>us_max) us_max=$14
                if ($14<us_min) us_min=$14 
                if ($15>sy_max) sy_max=$15
                if ($15<sy_min) sy_min=$15 
		if ("'"${sat}"'"==1 && $16==0) print
		}}
	}
	END {n = asort(rq_array,srq_array,"@val_num_asc")
	     if (n%2==1) median=srq_array[(n-1)/2+1]
	     else median=(srq_array[n/2]+srq_array[(n/2+1)])/2
	     #compute statistical mode from sorted array
	     hic=0; kc=0; fm=0; mode=0
	     for (k = 1; k <= n; k++) {
		if (srq_array[k]==srq_array[k+1]) {
			#inc match counter, if first match +2 else +1
			if (fm==0) { #first match of this value
				kc+=2
				fm=1
			}
			else { #subsequent match
				kc+=1
			}
			if (kc >= hic) { #mode is the most common value, but if two or more have identical count value, we take highest
				mode=srq_array[k]
				#update high count
				hic=kc
			}
		}
		else {
			#no match, reset counters
			kc=0
			fm=0
			}
		#Debug
		#print "Current:" srq_array[k]
		#print "Mode:Cnt" mode":"hic
	     }
	     printf ("   Mode CPU RQ: %5.1f\n",mode)
	     printf (" Median CPU RQ: %5.1f\n",median)
	     printf ("    Avg CPU RQ: %6.2f           Avg %CPU: %3.2f us %3.2f sy %3.2f id\n",i/c, us/c, sy/c, id/c)
	     printf ("Max/Min CPU RQ: %3d / %d     %CPU Max/Min: %d / %d us %d / %d sy %d / %d id\n",rq_max, rq_min, us_max, us_min, sy_max, sy_min, idl_max, idl_min)}'
}

awktally()
{
	awk 'BEGIN {i=0; m=0; id=0; us=0; sy=0; c=0; d=0; e=0; t=0; rq_max=0; rq_min=1024; idl_max=0; idl_min=100; us_min=100; us_max=0
                    sy_min=100; sy_max=0}
	/^# Starting Time:/ {stime[t]=$4" "$5; t++}
	/Median CPU/ {rq_array[d]=$4; d++}
	/Mode CPU/ {m_array[e]=$4; e++}
	/Avg CPU/ {i+=$4; id+=$11; sy+=$9; us+=$7; c++}
	/^Max/ {
	if ($4>rq_max) rq_max=$4 
	if ($6<rq_min) rq_min=$6
	if ($17>idl_max) idl_max=$17
	if ($19<idl_min) idl_min=$19
        if ($9>us_max) us_max=$9
        if ($11<us_min) us_min=$11 
        if ($13>sy_max) sy_max=$13
        if ($15<sy_min) sy_min=$15} 
	END {n = asort(rq_array,srq_array,"@val_num_asc")
	     m = asort(m_array,sm_array,"@val_num_asc") 
	     if (n%2==1) median=srq_array[(n-1)/2+1]
	     else median=(srq_array[n/2]+srq_array[(n/2+1)])/2
	     #compute statistical mode from sorted array
	     hic=0; kc=0; fm=0; mode=0
	     for (k = 1; k <= m; k++) {
		if (sm_array[k]==sm_array[k+1]) {
			#inc match counter, if first match +2 else +1
			if (fm==0) { #first match of this value
				kc+=2
				fm=1
			}
			else { #subsequent match
				kc+=1
			}
			if (kc >= hic) { #mode is the most common value, but if two or more have identical count value, we take highest
				mode=sm_array[k]
				#update high count
				hic=kc
			}
		}
		else {
			#no match, reset counters
			kc=0
			fm=0
			}
	     }
	     printf ("\nVmstatExaWatcher Data Set Summary of %d input files:\n",t)
	     printf ("    Start Time: %s  <-->   End Time: %s\n", stime[0], stime[t-1])	
	     if (mode==0) printf ("   Mode CPU RQ: none\n")
	     else printf ("   Mode CPU RQ: %4.2f ~ %3.2f%% of "'"${cpu_cnt}"'" HW CPU cores\n",mode, mode/"'"${cpu_cnt}"'"*100)
	     printf (" Median CPU RQ: %4.2f ~ %3.2f%% of "'"${cpu_cnt}"'" HW CPU cores\n",median, median/"'"${cpu_cnt}"'"*100)
	     printf ("    Avg CPU RQ: %5.2f ~ %3.2f%% of "'"${cpu_cnt}"'" HW CPU cores\n",i/c, (i/c)/"'"${cpu_cnt}"'"*100)
	     printf ("      Avg %CPU: %3.2f us %3.2f sy %3.2f id\n", us/c, sy/c, id/c)
	     printf ("Max/Min CPU RQ: %3d /%3d ~ %3.2f%% / %.2f%% of "'"${cpu_cnt}"'" HW CPU cores\n",rq_max,rq_min,rq_max/"'"${cpu_cnt}"'"*100,rq_min/"'"${cpu_cnt}"'"*100)
	     printf ("  %CPU Max/Min: %3d /%3d us %3d /%3d sy %3d /%3d id\n",us_max,us_min,sy_max, sy_min,idl_max,idl_min)}' /tmp/rpt.$$
}

usage()
{
	echo "usage: $(basename $0) [-s] [-c N] [-d DATE] fileglob" > /dev/stderr
	echo "   -s  prints vmstat details when CPU is saturated (idle = 0)" > /dev/stderr
	echo "   -c  set CPU core count (default 48 CPU cores)" > /dev/stderr
	echo "   -d  set date string easily, e.g." > /dev/stderr
	echo "        now, yesterday, -1week (lastweek), etc." > /dev/stderr
	echo "" > /dev/stderr
	echo "   fileglob (uses bash extended glob feature) of pattern match" > /dev/stderr
	echo "   of files to process. If DATE isn't specified, fileglob is required." > /dev/stderr
	echo "   E.G., all the files for June 2024:" > /dev/stderr
	echo "     $(basename $0) 2024_06" > /dev/stderr
	echo "   files for the week of May 19-21:" > /dev/stderr
	echo "     $(basename $0) 2024_06_?(19|20|21)" > /dev/stderr
	echo "     would match Exawatcher files:" > /dev/stderr
	echo "      2024_06_19_*VmstatExaWatcher_*.dat.bz2" > /dev/stderr
	echo "      2024_06_20_*VmstatExaWatcher_*.dat.bz2" > /dev/stderr
	echo "      2024_06_21_*VmstatExaWatcher_*.dat.bz2" > /dev/stderr
	echo "      2024_06_21_*VmstatExaWatcher_*.dat" > /dev/stderr
}

#disable saturation report by default
sat=0
#RA21 Spec default CPU core count
cpu_cnt=48

while getopts asc:d: o; do
	case $o in
		s)	#print CPU saturation event (idl = 0)
			sat=1
			;;
		c)	#override HW CPU core count (default is 48 (RA21))
			cpu_cnt=${OPTARG}
			;;
		d)	#easy way to specify a date string,
			#e.g. now, yesterday, -1week, etc
			files=$(date -d "${OPTARG}" '+%Y_%m_%d')* || exit 1
			;;
		a)	#consider all files
			files=*
			;;
		*)	usage
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))

shopt -s extglob

if [[ -z "${files}" ]]; then
	if [[ -z "${1}" ]]; then
		usage
		exit 1
	fi

	files=*${1}*
fi

for f in $files; do
	echo "-> ${f}:"
	if [[ ! -f "${f}" ]]; then
		echo "No file match. Check file glob string."
		#can't use variable here as loop in pipeline is executed in subshell with own context and environment
		touch /tmp/nogo.$$
		break
	fi
	if [[ ${f} =~ .bz2$ ]]; then
		bzcat -c "${f}" | myawk
	else
		myawk < "${f}"
	fi
done | tee -a /tmp/rpt.$$

if [[ -f /tmp/nogo.$$ ]]; then
	exit 1
fi

awktally
/bin/rm -f /tmp/rpt.$$ /tmp/nogo.$$

exit 0

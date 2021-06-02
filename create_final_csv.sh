#!/bin/bash
#Μετρητής χρόνου
start=$SECONDS
cd /Users/MYUSERNAME/diplomatiki_files


touch final_package_all_projects.csv
echo "project,version,name,software,software_version,type_of_reuse" >> final_package_all_projects.csv
find .  -name "*.csv" -exec mv {} /Users/MYUSERNAME/diplomatiki_files \;
#αντιγράφουμε το περιεχόμενο κάθε csv στο τελικό
find .  -name "final_package*.csv"  -type f | while read pack
do
while IFS=$\r read -r line ;do
echo "$line ">>final_package_all_projects.csv
done < $pack
done

#διαγράφουμε όλα τα υπόλοιπα csv και τους κενούς καταλόγους
find . -not -name "final_package_all_projects.csv"  -type f -delete
find . -type d -empty -delete

#σταματάει η χρονομέτρηση
if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)"
elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $minutes minute(s) and $seconds second(s)"
else
    echo "Completed in $SECONDS seconds"
fi

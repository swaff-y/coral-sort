#!/bin/bash

if [ -e $1 ]
then

#Prepare the file 
    cat  $1 | pgeta -p -c CH2O '{ *"type": *"login",' | cut -d\  -f 3,5,11- | sed 's/\([^ ]*\).* \(incoming\).* \([^{]*\).*sequence":\([^,]*\),"context":"\([^"]*\).*/\1,\2,\5-\4/; s/\([^ ]*\).* \(outgoing\).* \([^{]*\).*context": "\([^"]*\).*sequence": \([^,]*\).*/\1,\2,\4-\5/; s/  */ /g' > pgetfile.txt

#assign file to variable
    file=pgetfile.txt

#loop through incoming records 
    counter=0
    sum=0
    for n in $(grep "incoming" $file )
    do
#Get start time, and ID for each line. Then convert start time to seconds
        start_time=$(echo "$n" | cut -d\, -f 1)
	id=$(echo "$n" | cut -d\, -f 3)
        num=$(echo "$start_time" | cut -d. -f 1)
 	dec=$(echo "$start_time" | cut -d. -f 2)

	sec=$(echo "$(date -j -f "%H:%M:%S" "$num" "+%s")$dec")
#Get end time for associated record. Then convert end time to seconds       
        gotline=$(grep "outgoing,$id" $file) 
        end_time=$(echo "$gotline" |cut -d\, -f 1)
        gotnum=$(echo "$end_time" | cut -d. -f 1)
 	gotdec=$(echo "$end_time" | cut -d. -f 2)

        gotsec=$(echo "$(date -j -f "%H:%M:%S" "$gotnum" "+%s")$gotdec")
#Calculate the difference between start time and end time
        diff=$(($gotsec - $sec))
#Add the difference to the difference sum
        sum=$(($sum + $diff))
#Increment the counter to keep track of the number of records
        ((counter++))
    done 
#Calculate the average
    avg="$(($sum / $counter))"
#Convert average to decimals
    dec_avg=$(awk "BEGIN {print $avg/1000}")
#Display result
    echo "Average: $dec_avg seconds"
#remove file
    rm $file
else
    echo "That file does not exist"
fi

#!/bin/bash
if [ -e $1 ]
then
 
#Prepare the file 
    cat $1 | sed 's/\(message\).*/\1/; s/\(content\).*/\1/' | pgeta -p -c CH2O $2 'incoming|outgoing' | cut -d\  -f 1,2,3,5,11- | sed 's/  */ /g; s/": "/":"/g; s/ *{ "/ {"/g; s/e": /e":/g' > events.txt  

    file=events.txt

#Prepare display file
    $(echo "Date: SequenceId: IncomingType: OutgoingType: Duration:(seconds)" >> col.txt) 
    $(echo "----- ----------- ------------- ------------- ------------------" >> col.txt) 
#loop through events file    
    while IFS= read line 
    do
#       Get the incoming event and prepare the data
        n=$(echo "$line" | grep 'incoming' | sed 's/\(.*\) \(.*\) incoming .*\(type\)":"\([^"]*\).*sequence":\([^,]*\).*/\1 \2 \3 \4 \5/') 
#       Check if the line is not empty 
	if [ "$n" != "" ]
        then 
#           Assign variables to information that is needed
 	    inType=$(echo "$n" | cut -d\  -f 5)
	    inDate=$(echo "$n" | cut -d\  -f 2)
            start_time=$(echo "$n" | cut -d\  -f 3)
            num=$(echo "$start_time" | cut -d. -f 1)
            dec=$(echo "$start_time" | cut -d. -f 2)

            sec=$(echo "$(date -j -f "%H:%M:%S" "$num" "+%s")$dec")
        fi
#       Get the sequence number of the incoming line	
        inseq=$(echo "$line" | grep 'incoming' | sed 's/.*\(sequence":[^,]*\).*/\1/') 
#       Check if the sequence number is not empty
 	if [ "$inseq" != "" ]
        then
#           Find the outgoing sequence (match it)	
            outseq=$(echo $(grep ".*outgoing.*$inseq" $file))
            m=$(echo "$outseq" | grep 'outgoing' | sed 's/\(.*\) \(.*\) outgoing .*\(type\)":"\([^"]*\).*sequence":\([^,]*\).*/\1 \2 \3 \4 \5/')
	    outType=$(echo "$m" | cut -d\  -f 4)
 	fi
#       Get the end time from the outgoing sequence      
        end_time=$(echo "$outseq" | cut -d\  -f 2)
#       Check if the end time is not empty
        if [ "$end_time" != "" ]
        then
#           assign variables to the end time
            gotnum=$(echo "$end_time" | cut -d. -f 1)
            gotdec=$(echo "$end_time" | cut -d. -f 2)
            gotsec=$(echo "$(date -j -f "%H:%M:%S" "$gotnum" "+%s")$gotdec")
        fi
#       Check if all the information is present
        if [ "$sec" != "" ] && [ "$inseq" != "" ] && [ "$outseq" != "" ]
        then
#           make sure the order is right for subtraction
	    if [ "$gotsec" -gt "$sec" ]
	    then
                diff=$(($gotsec - $sec))
	    else
                diff=$(($sec - $gotsec))
	    fi
	    seqNo=$(echo "$inseq" | sed 's/.*:\(.*\)/\1/')
#           seconds=$(echo "scale=3; $diff/1000" | bc)
	    seconds=$(awk "BEGIN {print $diff/1000}")
	    pDate=$(echo "$inDate" | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')
#           add to a file to create cols
  	    doneLine=$(echo "$pDate $seqNo $inType $outType $seconds" >> col.txt)
        fi
#   progress indicator
    printf "#"
    done < events.txt
    echo ""
    cat col.txt | column -t
#   clean up files    
    rm col.txt
    rm events.txt
else
    echo "That file does not exist"
fi


#!/bin/bash
if [ -e $1 ]
then
 
#Prepare the file 
    cat $1 | sed 's/\(message\).*/\1/; s/\(content\).*/\1/' | pgeta -p -c CH2O $2 'incoming|outgoing' | cut -d\  -f 1,2,3,5,11- | sed 's/  */ /g; s/": "/":"/g; s/ *{ "/ {"/g; s/e": /e":/g; s/ /#/g; s/",#"con/","con/' > events.txt  

    file=events.txt

#Prepare display file
    $(echo "Date: IncomingTime: OutgoingTime: Duration:(seconds) SequenceId: IncomingType: Plugin: OutgoingType:" >> col.txt) 
    $(echo "----- ------------  ------------ ------------------  ---------- ------------- -------- -------------" >> col.txt) 
#loop through events file    
    for n in $(grep "incoming" $file)
    do
#       Get the incoming event and prepare the data
        m=$(echo "$n" | sed 's/#\(.*\)#\(.*\)#incoming#.*plugin":"\([^"]*\).*type":"\([^"]*\).*sequence":\([^,]*\).*/\1 \2 \4 \5 \3/; s/#\(.*\)#\(.*\)#incoming#.*type":"\([^"]*\).*sequence":\([^,]*\).*/\1 \2 \3 \4/;') 
#       Assign variables to information that is needed
        inType=$(echo "$m" | cut -d\  -f 3)
 	inDate=$(echo "$m" | cut -d\  -f 1)
        start_time=$(echo "$m" | cut -d\  -f 2)
        num=$(echo "$start_time" | cut -d. -f 1)
        dec=$(echo "$start_time" | cut -d. -f 2)
        inseq=$(echo "$m" | cut -d\  -f 4) 
        plugin=$(echo "$m" | cut -d\  -f 5) 
        sec=$(echo "$(date -j -f "%H:%M:%S" "$num" "+%s")$dec")
#       Find the outgoing sequence (match it) and get it ready for processing	
        outseq=$(echo $(grep ".*outgoing.*sequence\":$inseq" $file))
 	firstPart=$(echo "$outseq" | cut -d\  -f 1)
        q=$(echo "$firstPart" | grep 'outgoing' | sed 's/#\(.*\)#\(.*\)#outgoing#.*type":"\([^"]*\).*sequence":\([^,]*\).*/\1 \2 \4 \3/; s/#\(.*\)#\(.*\)#outgoing#.*sequence":\([^,]*\).*/\1 \2 \3/')
 	outType=$(echo "$q" | cut -d\  -f 4)
#       Get the end time from the outgoing sequence      
        end_time=$(echo "$firstPart" | cut -d\# -f 3)
#       Check if the end time is not empty
        diff=0
        if [ "$end_time" != "" ]
        then
#           assign variables to the end time
            gotnum=$(echo "$end_time" | cut -d. -f 1)
            gotdec=$(echo "$end_time" | cut -d. -f 2)
            gotsec=$(echo "$(date -j -f "%H:%M:%S" "$gotnum" "+%s")$gotdec")
#	    Calculate the difference
	    diff=$(($gotsec - $sec))
        fi
#       Check if the difference is greater than zero
        if [ "$diff" == "0" ]
        then
	    seconds="-"
	else
#	    convert to seconds
            seconds=$(echo "scale=3; $diff/1000" | bc)
            seconds=$(echo "$seconds" | sed 's/^\./0\./' )
        fi

 	pDate=$(echo "$inDate" | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3/')
#	check if all of the variables are present and assign a "-" to empty variables
        if [ "$plugin" == "" ]
	then
	   plugin="-"
	fi
	if [ "$outType" == "" ]
	then
	    outType="-"
	fi
	if [ "$end_time" == "" ]
	then
	    end_time="-"
	fi
#       Final line and add to file
        doneLine=$(echo "$pDate $start_time $end_time $seconds $inseq $inType $plugin $outType" >> col.txt)
#       progress indicator
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


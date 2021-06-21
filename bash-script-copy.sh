#!/bin/bash

if [ -e $1 ]
then


#   rm pgetfile.txt
#   rm modfile.txt

#Prepare the file 
    cat  $1 | pgeta -p -c CH2O '{ *"type": *"login",' | cut -d\  -f 3,5,11- | sed 's/  */ /g' > pgetfile.txt

#Read each line to change date and get sequence and context details

    file=pgetfile.txt
    i=1
    while IFS= read line
    do
        col1=$(echo "$line" | cut -d\  -f 1 ) 
	col2=$(echo "$line" | cut -d\  -f 2 )
	col3=$(echo "$line" | cut -d\  -f 3 )
        col3b=$(echo "$line" | cut -d\  -f 3- )

	num=$(echo "$col1" | cut -d. -f 1)
	dec=$(echo "$col1" | cut -d. -f 2)
	
        sec=$(echo "$(date -j -f "%H:%M:%S" "$num" "+%s")$dec")
   if [ $col2 == "incoming" ] 
   then
 	seq=$(echo "$col3" | jq .sequence)
 	cont=$(echo "$col3" | jq .context | sed 's/"//g')

         echo "$cont-$seq,$col2,$sec" >> modfile.txt

   elif [[ $col2 == "outgoing" ]]
   then
        seq=$(echo "$col3b" | cut -d\  -f 5 | sed  's/,"message"://')
 	cont=$(echo "$col3b" | cut -d\  -f 4 | sed 's/"//' | sed 's/","sequence"://')


        echo "$cont-$seq,$col2,$sec" >> modfile.txt 
   fi
   ((i++))
    done < "$file"

#Sort the file 

   sort modfile.txt

#Read each file into an array

   counter=0
   file2=modfile.txt
   while IFS= read line
   do
      ARRAY[$counter]=$line
      let counter=counter+1
   done < "$file2"

   length=${#ARRAY[@]}
 # echo ${ARRAY[0]}
 # echo $length

#Average calculation

   j=0
   sum=0
   transations=0
   for i in ${!ARRAY[@]}
   do
       if [[ "$i + 1" -lt "$length" ]] 
       then
           added="$i + 1"
           one=$(echo "${ARRAY[$i]}" | cut -d, -f 1)
	   two=$(echo "${ARRAY[$added]}" | cut -d, -f 1) 
        #  echo "$one $two"
	   if [[ "$one" == "$two" ]]
	   then
	       first=$(echo "${ARRAY[$i]}" | cut -d, -f 3)
	       second=$(echo "${ARRAY[$added]}" | cut -d, -f 3)
	       diff="$(($second - $first))"
               sum="$(($sum + $diff))"
               transactions="$(($transactions+1))"
	 #     echo $diff
	   fi
       fi
   done
    avg="$(($sum / $transactions))"
    dec_avg=$(awk "BEGIN {print $avg/1000}")
    echo "Average: $dec_avg seconds"

#remove calculation files

    rm pgetfile.txt
    rm modfile.txt

else
    echo "That file does not exist"
fi

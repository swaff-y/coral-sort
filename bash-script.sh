#!/bin/bash

if [ -e $1 ] || $1 != ''
then

    echo "True"
        
else
    echo "That file does not exist"
fi

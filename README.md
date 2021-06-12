# Coral - log file exercice
---
## Brief
Take the log file from the reef and display the average time between the incoming login event and the outgoing response.

## Instructions
Use any means necessary to achieve this. But the were some recommended paths to follow.

- Use unix commands like:
- grep, sed and corals command: pgeta

## approach
I Used pgeta command to sort the log file to get all the CH2O events. pgeta structures the data with the json attached to the event information

I struggled with the unix commands and so decided to use ruby to solve the problem.

## How to use File
1. Run the command cat <logFileName> | pgeta -p -c CH2O > <filename.txt>
2. Copy the file (sort.rb) into the directory with the file created in first step.
3. Run the command, ruby sort.rb "<filename.txt>"

## Output
The output is the average time it takes between the incoming event and the outgoing event.

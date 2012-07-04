#!/bin/bash 


for (( i=0 ; i < 2 ; i++ )) ; do 	
		echo "22308230" | mutt -a file.pdf -s 'test message' -- NAME@example.info
done

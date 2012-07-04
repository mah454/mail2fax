#!/bin/bash

#set -x

### Variables ###

home=/home/fax
user=$(whoami)
mailbox=/var/mail/$user


### Cleanup Temporary Files

function t_clear () {
	rm -rfv $home/RIP
	rm -rfv $home/email
	rm -rfv $home/messages
	rm -rfv $home/faxnumbers.txt
	rm -rfv $home/list.txt
}

### Functions ###

function send_fax () {
	for I in  $(cat $home/faxnumbers.txt)
	do 
			echo "NOTE : -----------> SEND FAX PROCESS <-----------" 
			for fax_file in $home/RIP/*.pdf
			do
				sendfax -vv -n -d $I $fax_file
			done
	done
}

function check_from () {
	mail_list=($(cat maillist.txt))
	for M in ${mail_list[@]}
	do
			if [ $f_mail == $M ] ; then
					echo
					echo "$f_mail is in list ..."
					send_fax
			fi
	done
}

t_clear

## ----- LOOP ---- >

while true
do
	
	num_mail=$(grep '^From ' $mailbox | wc -l )
	if [ $num_mail == 0 ] ; then 
			echo "NOTE : No message in mail box ..."
			break
	fi
	
	rm -rf messages
	[ ! -d messages ] && mkdir messages
	
	rm $home/mbox $home/sent
	
	#Split message to f_mail_dir
	echo $num_mail | mail > /dev/null
	
	# --------->
		f_mail=$(cat $home/mbox | formail -X "From " | awk '{print $2}')
		echo "From : $f_mail"
		RIP=$home/RIP
		rm -rf $RIP
		[ ! -d $RIP ] && mkdir $RIP
		
		echo
		ripmime --postfix -i $home/mbox -v -d $RIP
		
		faxnumbers=($(cat $RIP/textfile* | html2text | tr '\n' ' ' | tr -s ' ' ',' | tr ',' ' ' | tr ';' ' '))
		
		
		for F in ${faxnumbers[@]}
		do
			echo $F >> $home/list.txt
		done
		
		cat $home/list.txt | tr -d ' ' | tr -d '\t' | grep ^[0-9][0-9][0-9][0-9][0-9][0-9][0-9] | uniq > $home/faxnumbers.txt
		
		cat $home/faxnumbers.txt
		
		check_from
	
	# <---------
	rm $home/mbox $home/sent
	rm -rf $RIP/*

done

echo "###################### END #######################"

t_clear

exit 0

### <---- End While ----

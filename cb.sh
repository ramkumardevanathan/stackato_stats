#!/bin/bash

# this script creates bus files for vPV

# create user bus files
# role.useremail.bus
perl users.pl | awk 'BEGIN{heading="";}{
	if (NR == 1) { heading=$0; next; }
	if ($3 == "true") { print heading > "USER$!admin."$2".bus";
			print $0 >> "USER$!admin."$2".bus"; }
	if ($3 == "false") { print heading > "USER$!user."$2".bus";
			print $0 >> "USER$!user."$2".bus"; }
}'

# create app bus files
# useremail.appinst.bus


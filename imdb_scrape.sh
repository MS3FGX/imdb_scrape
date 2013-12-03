#!/bin/bash
#
# imdb_scrape: Search user-submitted IMDB data for keywords.
VER="1.0"
#
# This software is released under the BSD 3-Clause license. See the included
# file "LICENSE" for more information.
#
#-------------------------User Configuration Section---------------------------#

# Starting title
TT_START=87332

# Ending title
TT_END=87340

# Keyword
KEYWORD='spirit'

# Output file
LOG_FILE="results.txt"

# Delay in seconds
SCAN_DELAY=15

# Delete files after processing
KEEP_FILES=0

#------------------------No need to edit past this line------------------------#

# URL parts
URL_BASE="http://www.imdb.com/title/tt"
PAGE1="/parentalguide"
PAGE2="/reviews"

# Temp directory
TMP_DIR="/tmp"

ErrorMsg ()
{
# ErrorMsg  
# Displays either a minor (warning) or critical error, exiting on an critical.
# If message starts with "n", a newline is printed before message.
[[ $(expr substr "$2" 1 1) == "n" ]] && echo
if [ "$1" == "ERR" ]; then
	# This is a critical error, game over.
	echo "  ERROR: ${2#n}"
	exit 1
elif [ "$1" == "WRN" ]; then
	# This is only a warning, script continues but may not work fully.
	echo "  WARNING: ${2#n}"
fi
}

VerifyCmd ()
{
# VerifyCmd  
# Checks to see if given command exists, optional output.
[ $1 -eq 1 ] && echo -n "Checking for $2: "
if which $2 > /dev/null 2>&1; then
	[ $1 -eq 1 ] && echo "OK"
	return 0
else
	[ $1 -eq 1 ] && echo "FAILED"
	return 1
fi
}

CheckSys ()
{
# Check if tools are installed
VerifyCmd $1 grep
[ $? -eq 1 ] && ErrorMsg ERR "grep not found! Install to continue."
VerifyCmd $1 sed
[ $? -eq 1 ] && ErrorMsg ERR "sed not found! Install to continue."
VerifyCmd $1 awk
[ $? -eq 1 ] && ErrorMsg ERR "awk not found! Install to continue."
VerifyCmd $1 wget
[ $? -eq 1 ] && ErrorMsg ERR "wget not found! Install to continue."
}

GetTitle ()
{
# Return current movie title
TITLE=`grep "<title>" $TMP_DIR/PARENT$TT_CUR | awk -F"[>,<]" '{ print $3 }' | sed 's/.\{16\}$//'`
}

#---------------------------Execution starts here------------------------------#
case $1 in
'check')
echo "Checking system..."
CheckSys 1
;;
'clean')
echo "Removing old temp files..."
rm -f $TMP_DIR/PARENT*
rm -f $TMP_DIR/REVIEW*
;;
*)
clear
CheckSys 0
echo "imdb_scrape $VER"
echo "----------------"
echo "Start: $TT_START"
echo "End: $TT_END"
echo
# Loop through range
for((TT_CUR=$TT_START;TT_CUR<=$TT_END;++TT_CUR)) do

	# Download parent's guide page for current title
	echo -n "Fetching title $TT_CUR: "
	wget -q $URL_BASE$TT_CUR$PAGE1 -O $TMP_DIR/PARENT$TT_CUR
	wget -q $URL_BASE$TT_CUR$PAGE2 -O $TMP_DIR/REVIEW$TT_CUR
	# Get and display movie title
	GetTitle
	echo -n $TITLE
	
	# Run through grep
	if grep -iq $KEYWORD $TMP_DIR/*$TT_CUR ; then
		# Match found!
		echo " - HIT!"
		# Log title
		echo "$TT_CUR: $TITLE" >> $LOG_FILE
	else
		echo
	fi
	
	# Delete file
	[ $KEEP_FILES -eq 0 ] && rm -r $TMP_DIR/*$TT_CUR

	# Delay next fetch	
	sleep $SCAN_DELAY
done
;;
esac
#EOF

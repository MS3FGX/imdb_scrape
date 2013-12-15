#!/bin/bash
#
# imdb_scrape: Search user-submitted IMDB data for keywords.
VER="1.3"
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

# Number of 404's to accept before exiting
ERR_LIMIT=5

# Make sure page is valid IMDB entry before processing
IMDB_CHECK=0

# Configuration file, overrides above settings
CONFIG_FILE="scrape.conf"

#------------------------No need to edit past this line------------------------#

# Source external file to override local config
. $CONFIG_FILE

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

StartUp ()
{
# Sys check, boilerplate
clear
CheckSys 0
echo "imdb_scrape $VER"
echo "----------------"
}

DownloadPage ()
{
# Download the pages for TT_CUR
if wget -q $URL_BASE$TT_CUR$PAGE1 -O $TMP_DIR/PARENT$TT_CUR ; then
	wget -q $URL_BASE$TT_CUR$PAGE2 -O $TMP_DIR/REVIEW$TT_CUR
else
	echo "404 Page"
	((ERR_COUNT++))
	if [ $ERR_COUNT -eq $ERR_LIMIT ] ; then
		ErrorMsg ERR "Too many 404 pages, exiting."
		exit
	fi
		continue
fi 
}

GetTitle ()
{
# Return current movie title
TITLE=`grep "<title>" $TMP_DIR/PARENT$TT_CUR | awk -F"[><]" '{ print $3 }' | sed 's/.\{16\}$//'`
}

VerifyIMDB ()
{
# Verify the page we are looking at is actually from IMDB
grep -iq "imdb" $TMP_DIR/PARENT$TT_CUR || ErrorMsg ERR "nNot an IMDB page!"
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
rm -f $TMP_DIR/IMDB_TMP*
;;
'help')
clear
echo "imdb_scrape $VER"
echo "----------------"
echo "This script can be used to search the user-submitted data on IMDB.com for"
echo "specific keywords and phrases. The name of each movie that matches the"
echo "search terms will be written to the log file, along with the movie's"
echo "IMDB ID number."
echo
echo "Optionally, the script can save the matching pages, trimming and condensing"
echo "them down to a single file for each movie."
echo
echo "WARNING!"
echo "Use of this script is in direct violation of the IMDB Terms of Use."
echo
echo "The available arguments as of version $VER are as follows:"
echo "download   - Read the log file and download corresponding pages"
echo "process    - Trim down and merge pages into one file per movie"
echo "clean      - Remove downloaded files"
echo "help       - What you are reading now"
;;
'process')
StartUp
echo "Reading from: $LOG_FILE" 
echo "Processing files from: $TMP_DIR"
echo
# Loop through file
while read LINE
do
	# Read current title #
	TT_CUR=`echo $LINE | awk -F: '{print $1}'`
	echo "Processing $LINE"

	# Remove old temp files
	rm -f $TMP_DIR/IMDB_TMP*
	
	# Check for parent's guide and process
	if [ -s $TMP_DIR/PARENT$TT_CUR ] ; then
		# Remove all lines before first parent's guide category
		sed -i '1,/Sex &amp; Nudity/d' $TMP_DIR/PARENT$TT_CUR

		# Remove lines after "Report Problem", put into new file
		sed -n '/Report a problem/q;p' $TMP_DIR/PARENT$TT_CUR > $TMP_DIR/IMDB_TMP1
	else
		ErrorMsg WRN "Parents Guide not found."
	fi

	# Check for review and process
	if [ -s $TMP_DIR/REVIEW$TT_CUR ] ; then
		# Remove all lines before first horizonal bar
		sed -i '1,/<hr size="1" noshade="1">/d' $TMP_DIR/REVIEW$TT_CUR

		# Remove lines after second bar, put into new file
		sed -n '/<hr size="1" noshade="1">/q;p' $TMP_DIR/REVIEW$TT_CUR > $TMP_DIR/IMDB_TMP2
	else
		ErrorMsg WRN "Reviews not found."
	fi

	# Create final file, first line is movie title/ID
	echo $LINE > $TMP_DIR/TITLE_$TT_CUR

	# Merge together
	cat $TMP_DIR/IMDB_TMP* >> $TMP_DIR/TITLE_$TT_CUR 2>/dev/null || ErrorMsg ERR "Files not found!"
done < $LOG_FILE
echo "Complete"
;;
'download')
StartUp
echo "Reading from: $LOG_FILE" 
echo "Downloading pages to: $TMP_DIR"
echo
# Loop through file
while read LINE
do
	# Read current title #
	TT_CUR=`echo $LINE | awk -F: '{print $1}'`

	# Display entry
	echo $LINE

	# Download pages for current title
	DownloadPage
	
	# Delay next fetch	
	sleep $SCAN_DELAY
done < $LOG_FILE
;;
*)
StartUp
echo "Term: $KEYWORD"
echo "Titles: $TT_START through $TT_END"
echo
# Loop through range
for((TT_CUR=$TT_START;TT_CUR<=$TT_END;++TT_CUR)) do

	# Download pages for current title
	echo -n "Fetching title $TT_CUR: "
	DownloadPage

	# See if this is an IMDB page
	[ $IMDB_CHECK -eq 1 ] && VerifyIMDB

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
	
	# Delete files
	[ $KEEP_FILES -eq 0 ] && rm -f $TMP_DIR/*$TT_CUR

	# Delay next fetch	
	[ $TT_CUR -ne $TT_END ] && sleep $SCAN_DELAY
done
;;
esac
#EOF

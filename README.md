![IMDB](http://www.digifail.com/images/misc/github/imdb_logo_sm.jpg "IMDB Logo")

imdb_scrape
==============

imdb_scrape is a simple Bash script to "scrape" the user-submitted data on the
Internet Movie Database (www.imdb.com), namely, the "Parents Guide" and "User
Review" sections.

This script will let you specify the range of title ID numbers to search, the
keyword(s) you want to search for, and other options such as delay between
page requests and output log file.

Important!
==============

The TOS of the IMDB specifically forbids accessing their data through automated
methods such as this, and it's possible you can have your IP banned if you
abuse their service.

Understand that, if you use this script you're technically in violation of
IMDB's rules and regulations, and that there is no telling what (if anything)
will happen to you.

If you decide to use this software anyway, make use of the SCAN_DELAY option
in the configuration to wait a reasonable time before requesting a new page.

Functions
==============

Running imdb_scrape with no arguments will start it in default mode, which
searches IMDB based on the parameters setup in either the external
configuration file or the script's internal configuration section.

In addition, there are a few other functions which can be accessed by typing
the function name after the script. They are:

#### download
This function will read a previously created file of matching movies, and
download their pages. This function should be used if you intend on doing any
local processing of the files, removing the need to repeatedly pull the files
down from IMDB.

#### process
This function attempts to trim and condense the local files to make them more
manageable. It will remove a lot of the HTML from the downloaded files, and
merge them together into one file per movie which contains just (more or less)
the user-content.

#### clean
Remove the downloaded files. This will not remove the files created with the
"process" function, only the raw HTML which was saved with "download".

#### help
A quick intro to the script and listing of available functions.

Requirements
==============

This script requires a number of common Unix tools:

* sed
* awk
* wget
* grep

Every Unix/Linux distribution should include these tools, or at the very least,
have a way for you to easily install them.

It has been tested on Ubuntu, Mint, Slackware, and OpenWRT with no issues.

License
==============

This program is free software; you can redistribute it and/or modify it under
the terms of the BSD 3-Clause license.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

For details, see the "LICENSE" file.

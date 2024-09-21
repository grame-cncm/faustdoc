
function basename(file) {
    gsub(/\..*/, "", file);
    return file;
}

function getTagContent(str) {
	gsub(/}.*/ ,"",str);
	return str;
}

function getsection(str) {
	gsub(/!.*/ ,"",str);
	return str;
}

function gettag(str) {
	gsub(/[^!]*!/ ,"",str);
	return str;
}

function header(str) {
	return match(str, /\\[sub]{3,6}level/) || match(str, /\\label/);
}

function printheader(level, title) {
	print "\n" level " " title "\n" >> FILE;
}

BEGIN {
	START   = 0;
	PRINT   = 0;
	WAITLABEL = 0;
	SECTION = "";
	SECTIONNAME = "";
	FILE    = "";
	INDEX   = "index.md";
	SED     = "index.sed";
	MENU    = "menu.txt";
	FS      = "{";
	print > INDEX;
	print > SED;
	print > MENU;
	N       = 1;
}

END {
}


################# 
# files and headings
/\\chapter{/ 	{
	START = 1;
	SECTIONNAME = getTagContent($2)
	SECTION = "# " SECTIONNAME;
	WAITLABEL = 1;
	PRINT = 0;
}

/^\\label{/ {
	if (WAITLABEL) {
		label = N "-" getTagContent($2);
	 	FILE = label ".tmp";
	 	print "         - ' " SECTIONNAME "': " label >> MENU;
	 	N += 1;
	 	print "{!include.txt!}\n" > FILE;
	 	print SECTION >> FILE;
	 	print "\n" >> FILE;
	}
	WAITLABEL = 0;
	PRINT = 1;
}


################# 
# content but not comments
!/^[ 	]*%/ {
	if (PRINT) print $0 >> FILE; 
}

/\\index/ {
	if (PRINT) {
		ref = getTagContent($2);
		section = getsection(ref);
		tag = gettag(ref);
		mdfile =  basename(FILE);
		print section ": <a class=\"indexitem\" href=\"" mdfile "#" mdfile "-" tag "\">" tag "</a> " >> INDEX;
		print "s/\\" $0 "/<a name=\"" mdfile "-" tag "\"><\\/a>/" >> SED;
	}
}




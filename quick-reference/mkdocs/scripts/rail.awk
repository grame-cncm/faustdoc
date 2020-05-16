function basename(file) {
    gsub(/.*\//, "", file);
    gsub(/\..*/, "", file);
    return file;
}
  
function endrail(content, id) {
	file = basename(FILE);
	dstdir  = DSTDIR file;
	dstfile = dstdir "/" id ".rail";
#	print "endrail " dstfile " " file  " " id;
	system ( "[ -d " dstdir " ] || mkdir -p " dstdir );
	print content > dstfile;
	dst = MDDIR id ".html";
	print "\n<div class=\"rail\">\n<span class=\"railtitle\">"id"</span>\n<br /><script>\n{!"  MDDIR file "/" id ".js!}\n</script>\n</div>";
}

function makeID(str) {
	gsub(/[ \t]*/ ,"",str);  # remove spaces
	return str;
}

BEGIN {
	INRAIL= 0;
	FS     = ":";
	CAPTION = "";
	LABEL = "";
	FORMAT = "";
	PRINTFORMAT = 0;
	DSTDIR = "rail/"
	MDDIR = "rail/";
	ID = "";
}

################# 
# scan sample sections
/\\begin{rail}/ 	{ INRAIL = 1; WAITID = 1}
/\\end{rail}/ 		{ endrail(RAIL, ID); RAIL=""; INRAIL = 0; }

################# 
# content
!/\\begin{rail}/  {
	if (INRAIL) {
		if (WAITID) ID = makeID($1);
		WAITID = 0;
		RAIL = RAIL "\n" $0;
	}
	else print;	
}


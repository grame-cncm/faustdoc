
function getTagContent(str) {
	gsub(/}.*/ ,"",str);
	return str;
}

function tblcontent(str) {
	return index(str, "&");
}


function formatrow(line) {
	gsub(/\|/, "\\|", line);
	gsub(/[ 	]&/, " |", line);
	line = "| " line " |";
	return line;
}

function formatheader(line) {
	gsub(/\|/, "", line);
	gsub(/[^rlc]*/, "", line);
	gsub("r", "------:|", line);
	gsub("l", "------|", line);
	gsub("c", ":------:|", line);
	return "|" line;
}

function dummyheader(line) {
	gsub(/[^|]/, " ", line);
	return line;
}

function endtable(label, caption) {
	if (caption)
		print "\n<span class='caption'>" caption "</span>";
	CAPTION = "";
	LABEL = "";
	FORMAT = "";
	HEADERLESS = 1;
	PREV = "";
}

BEGIN {
	INTABLE= 0;
	INTABULAR= 0;
	FS     = "{";
	CAPTION = "";
	LABEL = "";
	FORMAT = "";
	HEADERLESS = 1;
	PREV = "";		# previous printed row, intended to manage the dummy row
}

END {
}

################# 
# scan sample sections
/\\begin{table/ 	{ INTABLE = 1; print "\n"; HEADERLESS=0; }
/\\end{table/ 		{ endtable(LABEL, CAPTION); INTABLE = 0; }
/\\begin{tabular}/ 	{ 
	format = formatheader(getTagContent($3));
	if (INTABLE && PREV) { FORMAT = format; print "\n"; }
	else {
		print dummyheader(format);
		print format;
		INTABULAR = 1;
	}
}
/\\end{tabular}/ 	{ endtable(LABEL, CAPTION); INTABULAR = 0; }

/\\caption/ 	{ if (INTABLE) CAPTION = getTagContent($2); }
/\\label/ 		{ if (INTABLE) LABEL = getTagContent($2); }
/\\centering/   {}

################# 
# content
!/\\centering/ {
	if (INTABLE || INTABULAR) {
		if (match($0, /[\\]&/)) PREV = $0;
		if ($0) print formatrow($0);
 		if (FORMAT && tblcontent($0)) {
 			print FORMAT;
	 		FORMAT = "";
	 	}
	}
	else print;	
}


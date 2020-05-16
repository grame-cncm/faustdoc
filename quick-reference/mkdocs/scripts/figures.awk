
function getTagContent(str) {
	gsub(/}.*/ ,"",str);
	gsub(/\..*/ ,"",str);
	return str;
}

function makefigure(label, caption, file, style) {
	closetag = ")";
# 	if (style) closetag = closetag style;
	if (label && file) print "![" label "](" file closetag;
	if (caption) print "<span class='caption'>" caption "</span>";
	if (file) {
		cmd = "cp " SRCF file " " DSTF file
		system ( cmd );
	}
	FILE = "";
	CAPTION = "";
	LABEL = "";
}

function getScale(tag) {
	gsub("\\\\includegraphics","",tag);
	gsub("\\[", "",tag);
	gsub("]", "",tag);
	i = index(tag, "=");
	scale = "";
	if (i) {
		mode = substr(tag, 0, i-1);
		scale = substr(tag, i+1);
		gsub (/\\..*/, "", scale);
		if (scale)
			scale = "{: style=\"width: " scale * 100 "%;\"}";
	}
	return scale;
}

BEGIN {
	SRCF = "../";
	DSTF = "../../mkdocs/docs/qreference/";
	INFIG= 0;
	FS      = "{";
	FILE = "";
	CAPTION = "";
	LABEL = "";
	SCALE = "";
}

END {
}

################# 
# scan sample sections
/\\begin{figure}/ 	{ INFIG = 1; }
/\\end{figure}/ 		{ makefigure(LABEL, CAPTION, FILE, SCALE); INFIG = 0; }

/\\includegraphics/ {
	FILE = getTagContent($2) ".png";
	SCALE = getScale($1);
}

/\\caption/ {
	if (INFIG) CAPTION = getTagContent($2);
}

/\\label/ {
	if (INFIG) LABEL = getTagContent($2);
}


################# 
# content
!/\\begin{figure}/  	{
	print $0; 
}

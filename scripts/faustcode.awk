
function makeFaust(code, i) {
	gsub(/`*/ ,"",code);
	current = "exfaust"i;
	folder = IMG"/"current;
	dsp = folder"/"current".dsp";
	svg = current"/"current".svg";
	cmd = "[ -d " DOCROOT"/"folder " ] || mkdir -p " DOCROOT"/"folder;
	system (cmd);
	out = DOCROOT"/"dsp;
	print code > out;
	print "<div class=\"faust-run\"><img src=\""svg"\" class=\"mx-auto d-block\">"
	# print "~~~";
	# print code;
	# print "~~~\n";
	# print "<a href=\"https://faustide.grame.fr/?code="FAUSTDOC"/"dsp"\" target=\"editor\">";
	# print "<button type=\"button\" class=\"btn btn-primary\">Try it Yourself >></button></a>";
	print "<faust-editor><!--";
	print code;
	print "--></faust-editor>";
	print "<br>";
	print "</div>";
	close(out);
}

BEGIN {
	FAUSTDOC = "https://faustdoc.grame.fr";
#	FAUSTDOC = "https://grame-cncm.github.io/faustdoc/";
	INDEX = 0;
	INFAUST = 0;
	FAUSTCODE = "";
	NL = "";
}

END {
	print "<script src=\"/faust-web-component.js\" defer></script>";
}

################# 
/<!-- \/faust-run -->/ 	{
	INFAUST = 0;
	makeFaust(FAUSTCODE, INDEX++);
	FAUSTCODE = "";
	NL = "";
}

/^.*/ { 
	if (INFAUST) {
		FAUSTCODE = FAUSTCODE NL $0;
		NL = "\n";
	}
	else print $0;
}

/<!-- faust-run -->/	{ 
	INFAUST = 1;
}

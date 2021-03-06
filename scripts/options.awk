

BEGIN {
#	STARTDOC = "<pre class=faust-tools>";
#	ENDDOC   = "</pre>;"
	STARTDOC = "~~~faust-options";
	ENDDOC   = "~~~";
}

END {
	print ENDDOC;
}

################# 
/^[A-Z]/ { 
	print "## " $0;
}

/^usage/ { 
	print STARTDOC;
}

/^[^A-Z]/ { 
	print $0;
}

/^----*/	{ 
	print STARTDOC;
}

/^$/	{ 
	print ENDDOC;
}


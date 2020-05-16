

BEGIN {
	FS      = "{";
}

END {
}


################# 
# content
!/\\end{equation}/ 		{ print $0;  }

################# 
# scan equation sections

/\\end{equation}/ 		{ print "\\]"; }

/\\begin{equation}/ 	{ print "\\["; }

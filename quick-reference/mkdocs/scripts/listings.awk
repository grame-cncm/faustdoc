

BEGIN {
	FS      = "{";
}

END {
}

################# 
# scan sample sections
/\\begin{lstlisting}/ 	{
		print "~~~~~~~~";
}
/\\end{lstlisting}/ 	{
		print "~~~~~~~~";
}

################# 
# content
/.*/ 	{
	print $0; 
}

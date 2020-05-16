
function getTagContent(str) {
	gsub(/}.*/ ,"",str);
	return str;
}

function insertFile(file) {
	cmd = "cat " SRCF file;
	system ( cmd );
}

BEGIN {
	SRCF = "../";
	FS  = "{";
}

################ 
# scan input sections
/\\input{/ 	{
	insertFile(getTagContent($2) ".tex");
}

################# 
# content
/.*/ 	{
	print $0; 
}

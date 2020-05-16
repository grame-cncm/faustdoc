/* lex.l - lexical analyzer for rail program */

%{

#include <string.h>

#include "gram.hpp"
#include "rail2js.h"

unsigned line;	/* current input line */

#define register


%}

SPACE	[ \t]
EOL		[\x0a\x0d]

%%

[a-zA-Z_][0-9a-zA-Z_.+*]* {
		return(IDENTIFIER);
}

[0-9][0-9]* {
		return(NUMBER);
}

'[^\n\t']*' {
		return(STRING);
}

\"[^\n\t\"]*\" {
		return(STRING);
}

{EOL} {
		line++;
}

"(" 	return OPENGROUP;
")" 	return CLOSEGROUP;
"[" 	return OPENANN;
"]" 	return CLOSEANN;
"|" 	return CHOICE;
"+" 	return LOOP;
":" 	return DEF;
";" 	return ENDEXPR;

{SPACE}+			;   /* eat up space */

.		return ERROR;	/* any extra text generates errors */

%%

int yywrap() { return(1); }

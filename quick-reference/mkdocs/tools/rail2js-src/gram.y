/* gram.y - yacc grammar for rail program */

%{

#include "rail2js.h"

using namespace std;

extern unsigned line;

typedef struct {} YY_BUFFER_STATE;
extern int yyparse();
extern YY_BUFFER_STATE yy_scan_string(const char *);

void yyerror (const char *s);
int yylex();
extern char* yytext;

#define TRACE 0

%}

/* identifier */

%token IDENTIFIER
%token NUMBER
%token STRING
%token OPENGROUP CLOSEGROUP OPENANN CLOSEANN CHOICE LOOP DEF ERROR ENDEXPR SKIP

%right CHOICE  CLOSEGROUP OPENGROUP
%left IDENTIFIER
/*%left IDENTIFIER CHOICE OPENGROUP CLOSEGROUP */


/*------------------------------   types  ------------------------------*/
%union
{
	struct node* node;
}

%type <node>	name expression nodename annotation group sequence choice loop 

%start rail

%%

rail : name DEF expression ENDEXPR	{ gExpression = new TExpression($1->fValue, $3); delete $1;}
	;

name : IDENTIFIER 	{ $$ = new TNode (kTerminal, yytext); }
		
expression: nodename		{ $$ = $1; }
	| sequence		{ $$ = $1; }
	| choice		{ $$ = $1; }
	| group			{ $$ = $1; }
	| loop			{ $$ = $1; }
	| annotation 	{ $$ = $1; } 
	;

nodename: IDENTIFIER	{ $$ = new TNode (kNonTerminal, yytext); 	if (TRACE) cerr << "nodename non term " << yytext << endl; }
	| STRING			{ $$ = new TNode (kTerminal, yytext); 		if (TRACE) cerr << "nodename term " << yytext << endl; }
	| NUMBER			{ $$ = new TNode (kTerminal, yytext); 		if (TRACE) cerr << "nodename number " << yytext << endl; }
	| SKIP				{ $$ = new TNode (kTerminal, "Skip()"); 	if (TRACE) cerr << "nodename Skip() " << yytext << endl; }
	;
	
annotation: OPENANN nodename CLOSEANN 	{ $2->fType = kAnnotation; $$ = $2; if (TRACE) cerr << "annotation " << endl; }
	;

group : OPENGROUP expression CLOSEGROUP  	{ $$ = $$ = new TNode (kGroup, $2); delete $2; if (TRACE) cerr << "create group" << endl; };
	| OPENGROUP expression CHOICE CLOSEGROUP { $$ = new TNode (kChoiceRight, ""); $$->add ($2); delete $2; if (TRACE) cerr << "create choice right" << endl;}
	| OPENGROUP CHOICE expression CLOSEGROUP { $$ = new TNode (kChoiceLeft, ""); $$->add ($3); delete $3; if (TRACE) cerr << "create choice left" << endl;}
	; 

choice : expression CHOICE expression { 
	if ($1->isChoice()) { $1->add ($3); $$ = $1; delete $3; }
	else { $$ = new TNode (kChoiceNode, ""); $$->add ($1, $3); delete $1; delete $3; }
	if (TRACE) cerr << "create choice" << endl;
} %prec CHOICE
	;

sequence : expression expression	{ 
	if ($1->isSeq()) { $1->add ($2); $$ = $1; delete $2; }
	else { $$ = new TNode (kSeqNode, ""); $$->add ($1, $2); delete $1; delete $2; }
	if (TRACE) cerr << "create seq" << endl; 
} %prec IDENTIFIER
	;

loop : expression LOOP 		{ $$ = new TNode (kLoopNode, ""); $$->add ($1); delete $1; if (TRACE) cerr << "create loop" << endl; }
	| loop expression		{ $$ = $1; $$->add ($2); delete $2; if (TRACE) cerr << "create loop expr" << endl; }
	;

%%

void yyerror(const char* s)
{
	cerr << "parse error line " << line << ": " << s << " " << yytext << endl;
	exit(1);
}

bool parse(const std::string& str)
{
	yy_scan_string(str.c_str());
	return !yyparse ();
}

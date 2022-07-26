

#include <iostream>
#include <fstream>
#include <streambuf>
#include <cstring>
#include "rail2js.h"

#ifdef YYDEBUG
extern int yydebug; /* show yacc debugging */
#endif

extern int yyparse();

using namespace std;

extern unsigned line;
extern bool parse(const string &str);

static void printJSNode(const TNode *node);
static void printJSSubNodes(const TNode *node);
static void printRailNode(const TNode *node);
static void printSubNodes(const TNode *node, const char *sep);

TExpression *gExpression = 0;

static void printSubNodes(const TNode *node, const char *sep)
{
	if (!node)
	{
		cerr << "\nprintSubNodes received unexpected null node" << endl;
		return;
	}
	size_t n = node->size();
	size_t i = 1;
	for (auto sub : node->fSubNodes)
	{
		printRailNode(&sub);
		if (i++ != n)
			cout << sep;
	}
}

static void printRailNode(const TNode *node)
{
	switch (node->fType)
	{
	case kSeqNode:
		printSubNodes(node, " ");
		break;
	case kChoiceNode:
		printSubNodes(node, " | ");
		break;
	case kChoiceRight:
		printSubNodes(node, " ");
		cout << "| ";
		break;
	case kChoiceLeft:
		cout << " | ";
		printSubNodes(node, " ");
		break;
	case kLoopNode:
		printSubNodes(node, " ");
		cout << "+ ";
		break;
	case kAnnotation:
		cout << "[" << node->fValue << "] ";
		break;
	case kTerminal:
	case kNonTerminal:
		cout << node->fValue << " ";
		break;
	case kGroup:
		cout << "(";
		printSubNodes(node, " ");
		cout << ")";
		break;
	default:
		cerr << "unexpected node type " << node->fType << endl;
	}
}

static void printJSSubNodes(const TNode *node)
{
	if (!node)
	{
		cerr << "\nprintSubNodes received unexpected null node" << endl;
		return;
	}
	size_t n = node->size();
	size_t i = 1;
	for (auto sub : node->fSubNodes)
	{
		printJSNode(&sub);
		if (i++ != n)
			cout << ", ";
	}
}

#if 0
#define trace node->fSubNodes.size()
#else
#define trace ""
#endif

static void printJSSeq(const TNode *node)
{
	if (node->size())
	{
		cout << "Sequence " << trace << " (";
		printJSSubNodes(node);
		cout << ")";
	}
	else
		printJSSubNodes(node);
}

static void printJSChoice(const TNode *node)
{
	if (node->size())
	{
		cout << "Choice " << trace << "(0, ";
		printJSSubNodes(node);
		cout << ")";
	}
	else
		printJSSubNodes(node);
}

static void printJSCheckSize(const TNode *node, const char *open)
{
	if (node->size())
	{
		cout << open;
		printJSSubNodes(node);
		cout << ")";
	}
	else
		printJSSubNodes(node);
}

static void printJSLoop(const TNode *node)
{
	if (node->size())
	{
		cout << "OneOrMore " << trace << " ( ";
		printJSSubNodes(node);
		cout << ")";
	}
	else
		printJSSubNodes(node);
}

static void printJSNode(const TNode *node)
{
	switch (node->fType)
	{
	case kSeqNode:
		printJSCheckSize(node, "Sequence (");
		break;
	case kChoiceNode:
		printJSCheckSize(node, "Choice (0, ");
		break;
	case kChoiceRight:
		cout << "Optional (";
		printJSSubNodes(node);
		cout << ") ";
		break;
	case kChoiceLeft:
		cout << "Optional " << trace << " ( ";
		printJSSubNodes(node);
		cout << ")";
		break;
	case kLoopNode:
		printJSCheckSize(node, "OneOrMore (");
		break;
	case kAnnotation:
		cout << "Comment ('" << node->fValue << "')";
		printJSSubNodes(node);
		break;
	case kTerminal:
		cout << node->fValue;
		break;
	case kNonTerminal:
		cout << "NonTerminal('" << node->fValue << "')";
		break;
	case kGroup:
		printJSSubNodes(node);
		break;
	default:
		cerr << "unexpected node type " << node->fType << endl;
	}
}

static void printRail(TExpression *exp)
{
	cout << exp->fName << " : " << endl
		 << "\t";
	printRailNode(exp->fNode);
}

static void printJS(TExpression *exp)
{
	cout << "ComplexDiagram(" << endl
		 << "\t";
	printJSNode(exp->fNode);
	cout << "\n).addTo()";
	cout << endl;
}

int main(int argc, char *argv[])
{
	int start = 1;
	bool latex = false;
	if ((argc > 2) && !strcmp(argv[1], "-latex"))
	{
		start = 2;
		latex = true;
	}
	for (int i = start; i < argc; i++)
	{
		const char *name = argv[i];
		ifstream file(name);
		if (file)
		{
			file.seekg(0, file.end);
			int length = file.tellg();
			file.seekg(0, file.beg);
			char *buffer = new char[length];
			file.read(buffer, length);

			string content(buffer, length);
			delete[] buffer;
			file.close();

			line = 1;
			parse(content);
			if (gExpression)
			{
				if (latex)
					printRail(gExpression);
				else
					printJS(gExpression);
				cout << endl;
			}
		}
		else
			cerr << "can't open file " << name << endl;
	}
	return 0;
}

void usage()
{
	cerr << "usage: rail2js <files>" << endl;
	exit(1);
}

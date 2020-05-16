
#pragma once

#include <iostream>
#include <string>
#include <vector>


enum { kSeqNode, kChoiceNode, kChoiceRight, kChoiceLeft, kChoiceSingle, kLoopNode, kAnnotation, kTerminal, kNonTerminal, kGroup };

typedef struct node {
	int 			fType;
	std::string 	fValue;
	std::vector<struct node> fSubNodes;

	node(int type, const char* value) : fType(type), fValue(value) {}
	node(int type, struct node* elt) : fType(type) { add(elt); }
	
	void add (const struct node* elt) 							{
		if ((elt->fType == fType) && ((fType == kSeqNode) || (fType == kChoiceNode))) {
			for (auto n: elt->fSubNodes) fSubNodes.push_back (n);
		}
		else fSubNodes.push_back(*elt);
		
	}
	void add (const struct node* elt1, const struct node* elt2) { add(elt1); add(elt2); }
	bool isSeq() const		{ return fType == kSeqNode; }
	bool isChoice() const	{ return fType == kChoiceNode; }
	size_t size() const		{ return fSubNodes.size(); }

} TNode;

typedef struct expression {
	std::string	fName;
	TNode * 	fNode;
	expression() : fNode(0) {}
	expression(const std::string& name, TNode* node ) : fName (name), fNode(node) {}
} TExpression;

extern TExpression* gExpression;

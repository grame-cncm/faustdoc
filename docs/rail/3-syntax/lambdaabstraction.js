ComplexDiagram(
	Sequence (NonTerminal('\'), '(', OneOrMore (NonTerminal('ident'), ','), ')', '.', '(', NonTerminal('expression'), ')')
).addTo()


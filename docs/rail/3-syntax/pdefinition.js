ComplexDiagram(
	Sequence (NonTerminal('identifier'), '(', OneOrMore (NonTerminal('pattern'), ','), ')', '=', NonTerminal('expression'), ';')
).addTo()


ComplexDiagram(
	Sequence (NonTerminal('identifier'), '(', OneOrMore (NonTerminal('parameter'), ','), ')', '=', NonTerminal('expression'), ';')
).addTo()


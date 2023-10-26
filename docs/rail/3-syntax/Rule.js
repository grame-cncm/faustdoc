ComplexDiagram(
	Sequence ('(', OneOrMore (NonTerminal('pattern'), ','), ')', "=>", NonTerminal('expression'), ';')
).addTo()


ComplexDiagram(
	Sequence ("waveform", NonTerminal('{'), OneOrMore (NonTerminal('number'), ','), NonTerminal('}'))
).addTo()


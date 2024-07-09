ComplexDiagram(
	Sequence (NonTerminal('expression'), 'letrec', NonTerminal('{'), OneOrMore (NonTerminal('diffequation')), Choice (0, Skip(), Sequence ('where', OneOrMore (NonTerminal('definition')))), NonTerminal('}'))
).addTo()


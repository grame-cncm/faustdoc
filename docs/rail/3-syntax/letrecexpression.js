ComplexDiagram(
	Sequence (NonTerminal('expression'), 'letrec', NonTerminal('{'), NonTerminal('diffequation+'), Choice (0, Skip(), Sequence ('where', NonTerminal('definition+'))), NonTerminal('}'))
).addTo()


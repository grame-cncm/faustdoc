ComplexDiagram(
	Sequence (Optional  ( Choice (0, '+', '-')), Choice (0, Sequence (NonTerminal('digit+'), '.', NonTerminal('digit*')), Sequence (NonTerminal('digit*'), '.', NonTerminal('digit+'))), Optional  ( NonTerminal('exponent')))
).addTo()


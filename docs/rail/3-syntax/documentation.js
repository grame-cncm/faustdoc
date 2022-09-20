ComplexDiagram(
	Sequence ("<mdoc>", OneOrMore (Choice (0, NonTerminal('freetext'), NonTerminal('equation'), NonTerminal('diagram'), NonTerminal('metadata'), NonTerminal('notice'), NonTerminal('listing'))), "</mdoc>")
).addTo()


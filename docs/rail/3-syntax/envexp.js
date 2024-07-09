ComplexDiagram(
	Choice (0, Sequence (NonTerminal('expression'), 'with', NonTerminal('{'), NonTerminal('definition+'), NonTerminal('}')), Sequence (NonTerminal('expression'), 'letrec', NonTerminal('{'), OneOrMore (NonTerminal('diffequation')), Choice (0, Skip(), Sequence ('where', OneOrMore (NonTerminal('definition')))), NonTerminal('}')), Sequence ('environment', NonTerminal('{'), OneOrMore (NonTerminal('definition')), NonTerminal('}')), Sequence (NonTerminal('expression'), '.', NonTerminal('ident')), Sequence ('library', '(', NonTerminal('filename'), ')'), Sequence ('component', '(', NonTerminal('filename'), ')'), Sequence (NonTerminal('expression'), '[', OneOrMore (NonTerminal('definition')), ']'))
).addTo()


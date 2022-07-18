
MAKE ?= make

CHAPTERS := $(wildcard chapters/*.tex)

.PHONY: mkdocs


all: 
	$(MAKE) latex
	$(MAKE) mkdocs

####################################################################
help:
	@echo "======================================================="
	@echo "                  Faust Quick Reference"
	@echo " This Makefile is intended to generate the faust quick "
	@echo " reference in pdf and md form (for mkdocs)"
	@echo "======================================================="
	@echo "Available targets are:"
	@echo "  all      : call the latex and mkdocs targets"
	@echo "  latex    : generates the pdf"
	@echo "  mkdocs   : generates md files for mkdocs"
	@echo "  menu     : generates menu items for mkdocs"
	@echo "  clean    : remove all the generated files"

####################################################################

latex: faust-quick-reference.pdf 

mkdocs: 
	$(MAKE) -C mkdocs

menu: 
	$(MAKE) -C menu


faust-quick-reference.pdf: faust-quick-reference.tex $(CHAPTERS)
	pdflatex faust-quick-reference.tex
	rail faust-quick-reference
	pdflatex faust-quick-reference.tex

clean:
	rm -f *.out *.toc *.pdf *.aux *.dvi *.rai *.rao *.log *.gz *~
	$(MAKE) -C mkdocs clean

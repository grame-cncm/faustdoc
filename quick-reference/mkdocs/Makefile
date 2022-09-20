
MAKE ?= make
AWK  ?= awk

SRCDIR   := ..
MKDOCS   := ../../mkdocs/docs
OUTDIR   := $(MKDOCS)/qreference
OUTCSS   := $(MKDOCS)/css
JSRAIL   := $(MKDOCS)/rail
SRC      := $(SRCDIR)/faust-quick-reference.tex

SPLIT    := $(wildcard *.tmp)
CHAPTERS := $(SPLIT:%.tmp=%.md)
MD  	 := $(SPLIT:%.tmp=$(OUTDIR)/%.md)
REFOUT 	 := $(CHAPTERS:%.md=%.refs)
RAIL 	 := $(shell find rail -name "*.rail")
RAILOUT  := $(RAIL:rail/%.rail=$(JSRAIL)/%.js)
RAILRSRC := rail/railroad-diagrams.css rail/railroad-diagrams.js
.PHONY: rail css

all:
	$(MAKE) split
	$(MAKE) fullrefs
	$(MAKE) md
	$(MAKE) rail
	$(MAKE) css
	$(MAKE) images


####################################################################
help:
	@echo "======================================================="
	@echo "                  Faust Quick Reference"
	@echo " This Makefile is intended to generate the faust quick "
	@echo " reference for mkdocs from the latex src code"
	@echo "======================================================="
	@echo "Available targets are:"
	@echo "  all      : generates all the necessary files from the latex documentation"
	@echo "Development specific targets are available:"
	@echo "  menu     : produce items for mkdocs.yml menu"

####################################################################

images : $(OUTDIR)/illustrations $(OUTDIR)/images $(OUTDIR)/graphs
	cp ../illustrations/*.png $(OUTDIR)/illustrations
	cp ../images/*.png $(OUTDIR)/images
	cp ../graphs/*.png $(OUTDIR)/graphs

menu:
	cat menu.txt | sed -e 's/\\faust/Faust/' | sed -e 's/: *\(.*\)/: qreference\/\1.md/'
 
md: $(OUTDIR) $(MD)
 
fullrefs : fullrefs.sed
fullrefs.sed : $(SPLIT)
	grep "\\label{" $(SPLIT) | sed -f scripts/labels.sed > $@

css :
	cp css/*.css $(OUTCSS)

split :
	$(AWK) -f scripts/scan-input.awk $(SRC) | $(AWK) -f scripts/split.awk 

rail: $(JSRAIL) tools/rail2js $(RAILOUT)
	cp $(RAILRSRC) $(JSRAIL)

$(OUTDIR):
	mkdir $(OUTDIR)
$(OUTDIR)/illustrations:
	mkdir $@
$(OUTDIR)/graphs:
	mkdir $@
$(OUTDIR)/images:
	mkdir $@
$(JSRAIL):
	mkdir $(JSRAIL)
	
test:
	@echo $(MD)

clean:
	rm -f $(SPLIT)
	rm -f $(MD)
	rm -f *.tmp
	rm -f menu.txt fullrefs.sed index.sed index.md
	rm -f rail/*/*.rail $(RAILOUT)
	$(MAKE) -C tools/rail2js-src clean

ignore:
	@echo *.tmp
	@echo $(MD) | tr " " "\n"
	@echo fullrefs.sed
	@echo 'index.*'
	@echo 'menu.txt'
	@echo 'rail/*/*.rail'
	@echo $(RAILOUT) | tr " " "\n"

$(OUTDIR)/%.md:%.tmp
	sed -f scripts/tags.sed $<  | $(AWK) -f scripts/tables.awk | $(AWK) -f scripts/rail.awk FILE=$< \
 	| $(AWK) -f scripts/figures.awk | $(AWK) -f scripts/listings.awk | $(AWK) -f scripts/equations.awk \
 	| sed -f fullrefs.sed | sed -f scripts/cleanup.sed  | grep -v __removed__ > $@

$(JSRAIL)/%.js: rail/%.rail
	@[ -d $(@D) ] || mkdir -p $(@D)
	tools/rail2js $< | sed -f scripts/rail.sed > $@ 

tools/rail2js:
	make -C tools/rail2js-src


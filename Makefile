
MAKE 	?= make
AWK		?= awk

MKDIR    := mkdocs
DOCDIR   := $(MKDIR)/docs
FAUSTDIR ?= ../../faust
EXDIR    ?= $(FAUSTDIR)/examples

SRC   	 := $(shell find src -name "*.md")
MD   	 := $(SRC:src/%=$(DOCDIR)/%)
DSP   	 := $(shell find $(DOCDIR) -name "*.dsp")
SVGDIRS  := $(shell find $(DOCDIR) -type d -name "exfaust*")
SVG   	 := $(DSP:%.dsp=%.svg)

EXSRC    := $(shell find $(EXDIR) -type d -d 1 | sort -f | grep -v old)
GEN      := $(EXSRC:$(EXDIR)/%=src/examples/%)
EXLIST   := $(EXSRC:$(EXDIR)/%=%)
EXOUT    := $(GEN:%=%.md)


GENERATED := $(shell find $(DOCDIR) -type d -name "exfaust*")
TOOLS    := $(wildcard $(FAUSTDIR)/tools/faust2appls/faust2*)

EDITOR      := https://fausteditor.grame.fr/

.PHONY: tagslist.txt


####################################################################
help:
	@echo "======================================================="
	@echo "                   Faust Documentation"
	@echo "This Makefile is intended to generate the faust documentation"
	@echo "======================================================="
	@echo "Available targets are:"
	@echo "  install  : install the required components"
	@echo "  build    : build the web site"
	@echo "  serve    : launch the mkdoc server"
	@echo "  all      : generates all the necessary files from the src folder"
	@echo "             actually call the 'md', 'options', 'tools', 'svg' and 'examples' targets"
	@echo "Development specific targets are available:"
	@echo "  md       : build the md files"
	@echo "  svg      : build the svg files"
	@echo "             the 'svg' target should be the last target called"
	@echo "  options  : build the compiler options page"
	@echo "  tools    : build the faust tools page"
	@echo "  examples : build the faust examples page"
	@echo "             call the 'md' target after the 'examples' target"
	@echo "  exlist   : list the examples for mkdocs.yml"
#	@echo "  zip      : create a zip file with all examples at the appropriate location"
	@echo "Making the current version publicly available:"
	@echo "  publish  : make all + build, switch to gh-pages and copy to root"
	@echo "             commit and push are still manual operations"

test: 
	@echo SVG: $(SVG)

####################################################################
build:
	cd $(MKDIR) && mkdocs build

serve:
	@echo "you can browse the site at http://localhost:8000"
	cd $(MKDIR) && mkdocs serve

all:
	$(MAKE) examples
	$(MAKE) md
	$(MAKE) options
	$(MAKE) tools
	$(MAKE) svg
#	$(MAKE) zip

clean:
	rm -f $(MD)
	rm -rf $(GENERATED)
	rm -f $(EXOUT)
	rm -rf $(SVGDIRS)

publish:
	$(MAKE) clean	# make sure previous svg output is removed
	$(MAKE) all
	$(MAKE) build
	git checkout gh-pages
	rm -rf examples guide refs	# clean previous folders
	cp -Rf $(MKDIR)/site/* .
	rm -rf $(MKDIR) src Makefile
	@echo "Review the changes, add new files, commit and push manually"
	@echo "... and switch back to master branch"
	

####################################################################
# building md and svg files
md : $(MD)

options: $(DOCDIR)/refs/options.md

$(DOCDIR)/refs/options.md:
	@echo "#Faust compiler options\n\n" > $@
	faust --help | $(AWK) -f scripts/options.awk >> $@

$(DOCDIR)/%.md:src/%.md 
	@echo ========= building $<
	@[ -d $(DOCDIR)/$* ] | mkdir -p $(DOCDIR)/$*
	cat $< | $(AWK) -f scripts/faustcode.awk IMG=$* DOCROOT=$(DOCDIR) > $@

svg : $(SVG)
%.svg:%.dsp
	faust -svg $< > /dev/null
	mv $(@D)/exfaust*-svg/process.svg $@
	rm -rf $(@D)/exfaust*-svg

####################################################################
# building tools doc
tools : $(FAUSTDIR) $(DOCDIR)/refs/tools.md 

$(DOCDIR)/refs/tools.md: src/refs/tools.md $(TOOLS)
	cat src/refs/tools.md > $@
	./scripts/buildtools $(TOOLS) >> $@

####################################################################
# building faust examples
examples : $(FAUSTDIR) src/examples $(EXOUT)

src/examples/%.md: $(EXDIR)/%
	@echo ========= building  $(*F) example
	$(eval tmp := $(shell ls $</*.dsp | grep -v 'multibandFilter\|guitarix\|mixer'))
	scripts/make-example $(*F) $(tmp) > $@

exlist :
	@echo $(foreach e, $(EXLIST), "        - '" $e "':  examples/"$e.md"\n")

src/examples:
	mkdir src/examples

####################################################################
# zip the faust examples
zip: 
	@[ -d $(DOCDIR)/rsrc ] || mkdir $(DOCDIR)/rsrc
	cd examples/mkdocs && zip -r examples examples 
	mv examples/mkdocs/examples.zip $(DOCDIR)/rsrc	

####################################################################
$(FAUSTDIR):
	@echo "FAUSTDIR not found ! ($(FAUSTDIR))"
	@echo "you should either:"
	@echo "   - set FAUSTDIR to the faust projet location in this Makefile"
	@echo "   - call $(MAKE) FAUSTDIR=faust_projet_path"
	@false;

####################################################################
install:
	pip install mkdocs
	pip install mkdocs-pdf-export-plugin
	pip install markdown-include
#	npm i railroad-diagrams

uninstall:
	pip uninstall -y mkdocs-material
	pip uninstall -y pymdown-extensions
	pip uninstall -y markdown-blockdiag
	pip uninstall -y mkdocs-pdf-export-plugin

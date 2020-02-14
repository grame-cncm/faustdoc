
MAKE 	?= make
AWK		?= awk

MKDIR    := mkdocs
DOCDIR   := $(MKDIR)/docs
FAUSTDIR ?= ../../faust

SRC   	 := $(shell find src -name "*.md")
MD   	 := $(SRC:src/%=$(DOCDIR)/%)
DSP   	 := $(shell find $(DOCDIR) -name "*.dsp")
SVG   	 := $(DSP:%.dsp=%.svg)

GENERATED := $(shell find $(DOCDIR) -type d -name "exfaust*")

TOOLS    := $(wildcard $(FAUSTDIR)/tools/faust2appls/faust2*)

TMP		 := __tmp.txt

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
	@echo "             actually call the 'md', 'options', 'tools' and 'svg' targets"
	@echo "Development specific targets are available:"
	@echo "  md       : build the md files"
	@echo "  svg      : build the svg files"
	@echo "  options  : build the compiler options page"
	@echo "  tools    : build the faust tools page"
#	@echo "  zip      : create a zip file with all examples at the appropriate location"
#	@echo "Making the current version publicly available:"
#	@echo "  publish  : make all + build, switch to gh-pages and copy to root"
#	@echo "             commit and push are still manual operations"

test: 
	@echo GENERATED: $(GENERATED)

####################################################################
build:
	cd $(MKDIR) && mkdocs build

serve:
	@echo "you can browse the site at http://localhost:8000"
	cd $(MKDIR) && mkdocs serve

all:
	$(MAKE) md
	$(MAKE) options
	$(MAKE) tools
	$(MAKE) svg
#	$(MAKE) zip

clean:
	rm -f $(MD)
	rm -rf $(GENERATED)

publish:
	$(MAKE) all
	$(MAKE) build
	git checkout gh-pages
	cp -Rf $(MKDIR)/site/* .
	@echo "Review the changes, add new files, commit and push manually"
	

####################################################################
# building md files
md : $(MD)

options: $(DOCDIR)/refs/options.md

$(DOCDIR)/refs/options.md:
	@echo "#Faust compiler options\n\n" > $@
	faust --help | awk -f scripts/options.awk >> $@

$(DOCDIR)/%.md:src/%.md 
	@echo ========= building $<
	@[ -d $(DOCDIR)/$* ] | mkdir -p $(DOCDIR)/$*
	cat $< | $(AWK) -f scripts/faustcode.awk IMG=$* DOCROOT=$(DOCDIR) > $@

svg : $(SVG)
%.svg:%.dsp
	faust -svg $< > /dev/null


####################################################################
# building tools doc
tools : $(FAUSTDIR) $(DOCDIR)/refs/tools.md 

$(DOCDIR)/refs/tools.md: src/refs/tools.md $(TOOLS)
	cat src/refs/tools.md > $@
	./scripts/buildtools $(TOOLS) >> $@


####################################################################
# building faust examples
examples : $(FAUSTDIR)
	echo building faust examples
	
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

chapters:
	cat tags.txt | cut -d':' -f 2 | sort -u
	
tagschapters:
	cat tags.txt | sed -e 's/\([^:]*\):\([^:]*\)/\2:\1/' | sed 's/ *//g' | sort -u
	
tagsindex:  $(DOCDIR)/refs/index.md

$(DOCDIR)/refs/index.md: Tags.txt
	cat Tags.txt | awk -f scripts/tagslist.awk > $(DOCDIR)/refs/index.md

####################################################################
# rules to convert gmn to html
$(DOCDIR)/GMN/examples/%.html: examples/mkdocs/examples/%.gmn
	@[ -d $(DOCDIR)/GMN/examples ] || mkdir $(DOCDIR)/GMN/examples
	sh scripts/guido2svg.sh $<	> $@

$(DOCDIR)/GMN/notes.html: examples/mkdocs/notes.gmn
	$(eval b64 := $(shell openssl base64 -in $< |  tr -d '\n'))
	@echo '<button class="try_it" onclick=window.open("$(EDITOR)?code=$(b64)")> Try it online </button>' > $@
	@echo '<div class="guido-code guido-medium">' >> $@
	@echo  >> $@
	guido2svg $< >> $@
	@echo '</div>' >> $@

$(DOCDIR)/GMN/%.html: examples/mkdocs/%.gmn
	$(eval b64 := $(shell openssl base64 -in $< |  tr -d '\n'))
	@echo '<button class="try_it" onclick=window.open("$(EDITOR)?code=$(b64)")> Try it online </button>' > $@
	@echo '<div class="guido-code">' >> $@
	@echo  >> $@
	guido2svg $< >> $@
	@echo '</div>' >> $@

$(DOCDIR)/examples/%.md: examples/mkdocs/examples/%.gmn
	@[ -d $(DOCDIR)/examples ] || mkdir $(DOCDIR)/examples
	$(eval name := $(patsubst $(DOCDIR)/examples/%.md, %, $@))	
	awk -v FILE=$(name) -f scripts/sample2md.awk $< > $@

####################################################################
# rules to convert gmn to base 64
%.b64.txt : %.gmn
	openssl base64 -in $< |  tr -d '\n' > $@


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

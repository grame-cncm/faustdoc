
MAKE 	?= make
AWK		?= awk

TMPTAGDIR := .tmptags

IGNORED  := "shareLocation|splitChord|chord|bembel|merge|port|shortFermata|color|colour|symbol|unit"
MKDIR    := mkdocs
DOCDIR   := $(MKDIR)/docs
TAGSDEST := $(DOCDIR)/refs/tags
FAUSTDIR ?= ../faust
SRCDIR   := $(GUIDODIR)/src/engine

INLINEGMN 	:= $(wildcard examples/mkdocs/*.gmn)
INLINEHTML 	:= $(INLINEGMN:examples/mkdocs/%.gmn=$(DOCDIR)/GMN/%.html)
GMNEXAMPLES := $(wildcard examples/mkdocs/examples/*.gmn)
HTMLEXAMPLES:= $(GMNEXAMPLES:examples/mkdocs/examples/%.gmn=$(DOCDIR)/GMN/examples/%.html) 
MDEXAMPLES  := $(GMNEXAMPLES:examples/mkdocs/examples/%.gmn=$(DOCDIR)/examples/%.md)
EXAMPLESMENU:= $(MDEXAMPLES:%.md=%.item)

EDITOR      := https://guidoeditor.grame.fr/

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
	@echo "  all      : generates all the necessary files from the src code or from gmn files"
	@echo "             actually call the 'tagfiles', 'tagsindex', 'gmn' and 'zip' targets"
	@echo "Development specific targets are available:"
	@echo "  tagfiles : create the tags documention md files from the src files"
	@echo "  zip      : create a zip file with all examples at the appropriate location"
	@echo "  gmnclean : remove the output of the gmn target"
	@echo "Making the current version publicly available:"
	@echo "  publish  : make all + build, switch to gh-pages and copy to root"
	@echo "             commit and push are still manual operations"

test: 
	@echo EXAMPLESMENU: $(EXAMPLESMENU)

####################################################################
build:
	cd $(MKDIR) && mkdocs build

serve:
	@echo "you can browse the site at http://localhost:8000
	cd $(MKDIR) && mkdocs serve

all:
	$(MAKE) tagfiles
	$(MAKE) tagsindex
	$(MAKE) gmn
	$(MAKE) zip
	cp -r Introduction $(DOCDIR)

publish:
	$(MAKE) all
	$(MAKE) build
	git checkout gh-pages
	cp -Rf $(MKDIR)/site/* .
	@echo "Review the changes, add new files, commit and push manually"
	

####################################################################
# building guido examples
gmn:
	$(MAKE) inlinegmn
	$(MAKE) examples
	
inlinegmn: $(INLINEHTML)

examples : $(MDEXAMPLES) $(HTMLEXAMPLES)

examplesmd : $(MDEXAMPLES)
exampleshtml : $(HTMLEXAMPLES)

gmnclean: 
	rm -f $(INLINEHTML) $(MDEXAMPLES) $(HTMLEXAMPLES)
	
menu: $(EXAMPLESMENU)

zip: 
	@[ -d $(DOCDIR)/rsrc ] || mkdir $(DOCDIR)/rsrc
	cd examples/mkdocs && zip -r examples examples 
	mv examples/mkdocs/examples.zip $(DOCDIR)/rsrc
	

####################################################################
tagfiles: $(FAUSTDIR)
	@rm -rf $(TMPTAGDIR)
	@[ -d $(TMPTAGDIR) ] || mkdir $(TMPTAGDIR)
	awk -v OUT=$(TMPTAGDIR) -f scripts/maketag.awk $(SRCDIR)/abstract/AR*.h
	@[ -d  $(TAGSDEST) ] || mkdir  $(TAGSDEST)
	mv -f $(TMPTAGDIR)/*.md $(TAGSDEST)

tagslist:
	$(MAKE) -C $(GUIDODIR)/build/ tags | egrep -v 'make|grep' | egrep -v $(IGNORED) | grep -v ^s$ | sort -u

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
# rule to generate the example menu items
$(DOCDIR)/examples/%.item : $(DOCDIR)/examples/%.md
	$(eval file := $(patsubst $(DOCDIR)/examples/%.item, %, $@))	
	@echo "        - '$(shell egrep '^# ' $< | sed 's/# *//' | sed 's/ *$$//')': examples/$(file).md"


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

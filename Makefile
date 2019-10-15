REMOTE=lab:/proj/www/sra.uni-hannover.de/Lehre/V_PSÜ/skript/.

ORG_PDF=$(shell echo 0*.org)
ORG=$(filter-out export-prologue.org, $(filter-out setup.org, $(shell echo *.org)))

PDF=$(foreach i,${ORG_PDF},$(patsubst %.org,build/%.slides.pdf,${i}))
HTML=$(foreach i,${ORG},$(patsubst %.org,build/html/%.html,${i}))

export TEXINPUTS := ./texmf-local//:./texmf//:${TEXINPUTS}

all: slides html

slides: ${PDF}

html: ${HTML}

build: texmf/ls-R
	@mkdir -p build/tangle
	@mkdir -p build/html
	@ln -fs ../export-prologue.org build
	@ln -fs ../../html/css build/html/
	@ln -fs ../../html/js build/html/
	@ln -fs ../../fig     build/html
	@ln -fs ../../lst     build/html



texmf/ls-R:
	texhash texmf/

# Building the figures is only a precondition for this makefile. This is the easy part.
fig/%.pdf: fig/%.tex texmf-local/lecturefig.cls
	@${MAKE} build
	latexmk -pdf $< -outdir=build
	@cp $(patsubst fig/%,build/%,$@) $@

define CREATE_SUB # $(1) = 01, $(2) = 01-einleitung
build/$(2).slides.pdf build/$(2).handout.pdf: $(shell find fig/ -name "$(1)-*.pdf")
$(1):                 build/$(2).slides.pdf
$(1).view:            build/$(2).slides.pdf
$(1).handout:         build/$(2).handout.pdf
$(1).handout.view:    build/$(2).handout.pdf
$(1).tangle:          build/tangle/$(2).tex
$(1).split:           build/html/$(2).slides/.split-stamp
$(1).handout.split:   build/html/$(2).handout/.split-stamp
$(1).html:            build/html/$(2).html
$(1).html.view:       build/html/$(2).html
$(1).handout.html:    build/html/$(2).handout.html
$(1).handout.html.view:  build/html/$(2).handout.html
$(1).all:             $(1).html $(1).handout $(1).handout.html
$(1).wc:
	@awk 'BEGIN {IGNORECASE=1; p=1}; /#\+begin_src/ {p=0}; {if(p) print};  /#\+end_src/ {p=1}' < $(2).org | wc -w
$(1).publish:   build/html/index.html $(1).all
	cd build/html; rsync -aLv  ./index.html ./css ./js ./lst ./fig ./$(2)* ${REMOTE}
endef

%.view:
	xdg-open $< &

# invoke it for lecture PDF target (01-Einfuehrung.pdf, ...)
$(foreach f,$(ORG_PDF),\
	$(eval $(call CREATE_SUB,$(shell echo $(f) | awk -F- '{print $$1;}'),$(f:.org=)))\
)

################################################################
# Setup the Emacs server
EC=make -s emacs/ensure; emacsclient -s psu

emacs/start:
	@emacs -q -l site-lisp/init.el --daemon=psu
	@echo "Started Emacs"

emacs/stop:
	@emaacsclient -s psu  -e '(kill-emacs 0)' >/dev/null 2>&1 || true
	@pgrep -l -f "^emacs.*--daemon=psu" || true
	@pkill -f "^emacs.*--daemon=psu" || true

emacs/restart: emacs/stop emacs/start

emacs/ensure:
	@emacsclient -s psu -e 't' >/dev/null 2>&1 || make -s emacs/restart


################################################################
# With the emacs server, we can tangle the beamer slides from
# the org file.

build/tangle/%.tex: %.org
	@mkdir -p build/tangle
	${EC} -e '(org-babel-tangle-file "'"$$PWD"'/$<" nil "latex")'
	mv $(patsubst %.org,%.tex,$<) $@
	bin/delete-frames $@

build/%.slides.tex: build/tangle/%.tex build
	@echo "\\documentclass[beamer,xcolor={table,rgb,dvipsnames}]{beamer}\\input{preamble}\\\\begin{document}\\\\input{$<}\\\\end{document}" > $@

build/%.handout.tex: build/tangle/%.tex build
	@echo "\\documentclass[handout,xcolor={table,rgb,dvipsnames}]{beamer}\\input{preamble}\\\\begin{document}\\\\input{$<}\\\\end{document}" > $@

build/tangle/%.html: %.org
	${EC} -e "(org-export-to-html-file \"$$PWD/$<\" \"$$PWD/$@\")"


build/%.pdf: build/%.tex
	latexmk -pdf $< -outdir=build
	@cp $@ build/html

################################################################
# For the HTML version, we split the PDF file into many files
# and convert them to SVG. These files are
build/html/%/.split-stamp: build/%.pdf bin/split-pdf
	mkdir -p $(patsubst build/%.pdf,build/html/%,$<)
	rm -f $(patsubst build/%.pdf,build/html/%,$<)/*.pdf
	rm -f $(patsubst build/%.pdf,build/html/%,$<)/*.svg
	bin/split-pdf $< $(patsubst %.pdf,%.topics,$<)
	@touch $@

build/html/%.html: %.org build/html/%.handout/.split-stamp bin/insert-carousels
	bin/insert-carousels $< $(patsubst %.org,build/%.handout.topics,$<) \
		> $(patsubst %.org,build/%.org,$<)
	${EC} -e "(org-export-to-html-file \"$$PWD/build/$<\" \"$$PWD/$@\")"

build/html/%.handout.html: %.org build/html/%.handout/.split-stamp bin/insert-carousels
	bin/insert-carousels $< $(patsubst %.org,build/%.handout.topics,$<) \
		> $(patsubst %.org,build/%.handout.org,$<)
	${EC} -e "(org-export-to-html-file \"$$PWD/$(patsubst %.org,build/%.handout.org,$<)\" \"$$PWD/$@\")"

# Special cases for the index file
build/tangle/index.html: $(shell echo *.org)
index index.view: build/html/index.html
build/html/index.html: build/tangle/index.html
	cp $< $@



clean: emacs/stop
	rm -rf build
	rm -f texmf/ls-R


.PRECIOUS: build/%.pdf build/tangle/%.tex build/%.pdf.split build/%.tex
.PHONY:  build

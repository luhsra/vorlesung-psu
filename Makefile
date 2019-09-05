ORG_PDF=$(shell echo 0*.org)
ORG=$(filter-out export-prologue.org, $(shell echo *.org))

PDF=$(foreach i,${ORG_PDF},$(patsubst %.org,build/%.pdf,${i}))
HTML=$(foreach i,${ORG},$(patsubst %.org,build/html/%.html,${i}))

export TEXINPUTS := ./texmf-local//:./texmf//:${TEXINPUTS}

all: slides html

slides: ${PDF}

html: ${HTML}

build: texmf/ls-R
	@mkdir -p build/tangle
	@mkdir -p build/html
	@ln -fs ../../export-prologue.org build/html
	@ln -fs ../../html/css build/html/
	@ln -fs ../../html/js build/html/

texmf/ls-R:
	texhash texmf/


define CREATE_SUB
prefix :=
build/$(1:.org=.pdf): $(shell prefix=`echo $(1) | awk -F- '{print $$1;}'`; echo fig/$${prefix}-*.pdf)
$(shell echo $(1) | awk -F- '{print $$1;}'): build/$(1:.org=.pdf)
$(shell echo $(1) | awk -F- '{print $$1;}').html : build/html/$(1:.org=.html)
$(shell echo $(1) | awk -F- '{print $$1;}').tangle : build/tangle/$(1:.org=.tex)
$(shell echo $(1) | awk -F- '{print $$1;}').split: build/$(1:.org=.pdf.split)
endef
# invoke it for lecture PDF target (01-Einfuehrung.pdf, ...)
$(foreach f,$(ORG_PDF),\
	$(eval $(call CREATE_SUB,$(f)))\
)

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
	@emacsclient -s psu -e 't' >/dev/null 2>&1 || make -s emacs/start


# We use the emacs server to tangle the shit out of it
build/tangle/%.tex: %.org
	@mkdir -p build/tangle
	${EC} -e '(org-babel-tangle-file "'"$$PWD"'/$<" nil "latex")'
	mv $(patsubst %.org,%.tex,$<) $@
	bin/delete-frames $@


build/tangle/%.html: %.org  export-prologue.org
	${EC} -e "(org-export-to-html-file \"$$PWD/$<\" \"$$PWD/$@\")"

build/%.tex: build/tangle/%.tex build
	@echo "\\input{preamble}\\\\begin{document}\\\\input{$<}\\\\end{document}" > $@

build/%.pdf: build/%.tex
	latexmk -pdf $< -outdir=build

fig/%.pdf: fig/%.tex texmf-local/lecturefig.cls
	@mkdir -p build
	latexmk -pdf $< -outdir=build
	@echo "make: hard link from build/ to $@"
	@cp $(patsubst fig/%,build/%,$@) $@


build/%.pdf.split: build/%.pdf bin/split-pdf
	bin/split-pdf $< $(patsubst %.pdf,%.topics,$<)
	touch $@

build/html/index.html: build/tangle/index.html
	cp $< $@

build/html/%.html: %.org build/tangle/%.html build/%.pdf.split bin/insert-carousels
	cp $(patsubst %.org, build/%.pdf,$<) $(patsubst %.org, build/html/%-slides.pdf,$<)
	bin/insert-carousels $< $(patsubst %.org,build/%.topics,$<) \
            > $(patsubst %.org,build/html/%.org,$<)
	${EC} -e "(org-export-to-html-file \"$$PWD/build/html/$<\" \"$$PWD/$@\")"




clean: emacs/stop
	rm -rf build
	rm -f texmf/ls-R


.PRECIOUS: build/%.pdf build/tangle/%.tex build/%.pdf.split build/%.tex
.PHONY:  build

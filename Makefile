ORG_PDF=$(shell echo 0*.org)
ORG=$(shell echo *.org)

PDF=$(foreach i,${ORG_PDF},$(patsubst %.org,build/%.pdf,${i}))
HTML=$(foreach i,${ORG},$(patsubst %.org,build/html/%.html,${i}))


all: slides html

slides: ${PDF}

html: ${HTML}

build:
	@mkdir -p build/tangle
	@mkdir -p build/html
	@ln -fs ../../html/css build/html/
	@ln -fs ../../html/js build/html/

# Generate shortcut targets:
#
# invoked with <prefix>-<rest>.pdf adds a set of rules
#    <prefix> : <prefix>-<rest>.pdf
#    <prefix>.dep : <prefix>-<rest>.dep
#    <prefix>_handout : <prefix>-<rest>_handout.pdf
#    <prefix>_notes : <prefix>-<rest>_notes.pdf
#    <prefix>_all : <prefix>-<rest> <prefix>-<rest>_handout <prefix>-<rest>_notes
#
define CREATE_SUB
$(shell echo $(1) | awk -F- '{print $$1;}') : build/$(1:.org=.pdf)
$(shell echo $(1) | awk -F- '{print $$1;}').html : build/html/$(1:.org=.html)
endef
# invoke it for lecture PDF target (01-Einfuehrung.pdf, ...)
$(foreach f,$(ORG_PDF),\
	$(eval $(call CREATE_SUB,$(f)))\
)



# We use the emacs server to tangle the shit out of it
build/tangle/%.tex: %.org
	emacsclient -e '(org-babel-tangle-file "'"$$PWD"'/$<" nil "latex")'
	mv $(patsubst %.org,%.tex,$<) $@

build/tangle/%.html: %.org
	emacsclient -e "(org-export-to-html-file \"$$PWD/$<\" \"$$PWD/$@\")"

build/%.tex: build/tangle/%.tex build
	@echo "\\input{preamble}\\\\begin{document}\\\\input{$<}\\\\end{document}" > $@

build/%.pdf: build/%.tex
	latexmk -pdf $< -outdir=build

build/%.pdf.split: build/%.pdf bin/split-pdf
	bin/split-pdf $< $(patsubst %.pdf,%.topics,$<)
	touch $@

build/html/index.html: build/tangle/index.html
	cp $< $@

build/html/%.html: build/tangle/%.html build/%.pdf.split bin/insert-carousels
	bin/insert-carousels $< $(patsubst build/tangle/%.html,build/%.topics,$<) \
            > $(patsubst build/tangle/%.html,build/html/%.html,$<)

clean:
	rm -rf build


.PRECIOUS: build/%.pdf build/tangle/%.tex build/%.pdf.split build/%.tex
.PHONY:  build

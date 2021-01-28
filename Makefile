export TEXINPUTS := ./texmf-local//:./texmf//:${TEXINPUTS}

EMACS_SESSION=psu

# ORG_SLIDES: Which ORG files should be tangled into .tex files and
# translated into PDF files.
ORG_SLIDES=$(wildcard 0*.org 1*.org)

# ORG_HTML: Which ORG files are translated, without PDF processing,
# into html files.
ORG_HTML=index.org

#REMOTE_SEVER ?= lab
#REMOTE=${REMOTE_SERVER}:/proj/www/sra.uni-hannover.de/Lehre/V_PSÜ/skript/.

REMOTE=/tmp/remote

build: texmf/ls-R
texmf/ls-R:
	mktexlsr texmf/
ARTIFACTS += texmf/ls-R

include org-lecture/common.mk

$(eval $(call PROCESS_STAMP,01,fig/01-t-diagram.pdf,5))
$(eval $(call PROCESS_STAMP,02,fig/02-grammar.pdf,1))
$(eval $(call PROCESS_STAMP,03,fig/03-polymorphismus.pdf,0))
$(eval $(call PROCESS_STAMP,04,fig/04-instances.pdf,0))
$(eval $(call PROCESS_STAMP,05,fig/05-js-triangle.pdf,0))
$(eval $(call PROCESS_STAMP,06,fig/06-val-refs.pdf,1))
$(eval $(call PROCESS_STAMP,07,fig/07-ite.pdf,1))
$(eval $(call PROCESS_STAMP,08,fig/08-codegen-add.pdf,0))
$(eval $(call PROCESS_STAMP,09,fig/09-optimization-depends.pdf,0))
$(eval $(call PROCESS_STAMP,10,fig/10-stamp.pdf,0))
$(eval $(call PROCESS_STAMP,11,fig/11-call-hierarchy.pdf,0))
$(eval $(call PROCESS_STAMP,12,fig/12-function.pdf,0))
$(eval $(call PROCESS_STAMP,13,fig/13-fin.pdf,0))

$(eval $(call PROCESS_PDF2PNG,fig/05-dependency-tree.pdf,1))
03.html: fig/05-dependency-tree-1.png

# Special cases for the index file
build/html/index.html: $(ORG_HTML) $(ORG_SLIDES) COPYING.footer.html

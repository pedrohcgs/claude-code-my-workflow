#DEFINITIONS

SHELL=bash

SLIDES_SECTIONS := $(shell grep '\\input{' slides.tex | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\).*/\1/')
TEX_INPUTS := $(shell grep '\\input{.*\.tex}' $(SLIDES_SECTIONS) | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\).*/\1/')
IMG_INPUTS := $(shell grep '\\includegraphics' $(SLIDES_SECTIONS) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\([\./a-zA-Z0-9_]*\)}.*/\1/')
SLIDES_INPUTS := $(shell grep --no-filename 'input/' $(SLIDES_SECTIONS) slides.tex | grep -v '^%' | grep -o 'input/[A-Za-z0-9_\.\-]*\.[a-z]*')

all: slides.pdf

.PHONY: clean inputs
clean:
	rm -f *.log *.aux *.out *.toc *.snm *.nav *.blg *.bbl
inputs: $(SLIDES_INPUTS)

input/:
	mkdir $@

slides.pdf: slides.tex $(SLIDES_SECTIONS) $(TEX_INPUTS) $(IMG_INPUTS)
	if command -v sbatch > /dev/null ; then module load texlive; fi
	xelatex -draftmode $<
	BIBINPUTS=../bib:$$BIBINPUTS bibtex $(basename $<).aux
	xelatex -draftmode $<
	xelatex $<
	rm -f $(addprefix $(basename $<),.log .aux .out .toc)
	rm -f $(addprefix $(basename $<),.snm .nav)
	rm -f $(addprefix $(basename $<),.blg .bbl)

slides_notesonly.pdf: slides.tex $(SLIDES_SECTIONS) $(TEX_INPUTS) $(IMG_INPUTS)
	sed 's/notes=hide/notes=only/' slides.tex > slides_notesonly.tex
	xelatex slides_notesonly.tex
	rm -f slides_notesonly.tex slides_notesonly.log

#INPUT RECIPES

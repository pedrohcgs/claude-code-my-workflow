## DEFINITIONS

SHELL=bash

PAPER_SECTIONS = $(shell grep -v '%.*input' paper.tex | grep -o 'sections/[A-Za-z_]*\.tex')
PAPER_INPUTS = $(shell grep --no-filename 'input/' $(PAPER_SECTIONS) paper.tex | grep -v '^%.*\\input' | grep -o 'input/[A-Za-z0-9_\.\-]*\.[a-z]*')

## RECIPES

all: paper.pdf

paper.pdf: paper.tex $(PAPER_SECTIONS) $(PAPER_INPUTS)
	if command -v sbatch > /dev/null ; then module load texlive; fi
	pdflatex -draftmode $<
	BIBINPUTS=../bib:$$BIBINPUTS bibtex $(basename $<).aux
	pdflatex -draftmode $<
	pdflatex $<
	rm -f $(addprefix $(basename $<), .aux .log .out)
	-rm -f $(addprefix $(basename $<), .bbl .blg)

.PHONY: clean inputs
clean:
	-rm -f *.aux *.log *.out
	-rm -f *.toc *.bbl *.blg
inputs: $(PAPER_INPUTS)

input/:
	mkdir $@

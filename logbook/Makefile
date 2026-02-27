SHELL=bash

all: logbook.pdf

logbook.pdf: logbook.tex $(wildcard entries/*.tex)
	if command -v sbatch > /dev/null ; then module load texlive; fi
	pdflatex $<
	pdflatex $<
	rm -f $(addprefix $(basename $<), .aux .log .out .toc)

.PHONY: clean
clean:
	-rm -f *.aux *.log *.out *.toc

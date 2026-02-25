#DEFINITIONS

SLIDES_SECTIONS := $(shell grep '\\input{' slides.tex | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\).*/\1/')
TEX_INPUTS := $(shell grep '\\input{.*\.tex}' $(SLIDES_SECTIONS) | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\).*/\1/')
IMG_INPUTS := $(shell grep '\\includegraphics' $(SLIDES_SECTIONS) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\([\./a-zA-Z0-9_]*\)}.*/\1/')

all: slides.pdf

clean:
	rm *.log *.aux

input/:
	mkdir $@

slides.pdf: slides.tex $(SLIDES_SECTIONS) $(TEX_INPUTS) $(IMG_INPUTS)
	#module load texlive
	#pdflatex -draftmode $<
	#bibtex slides.aux
	pdflatex -draftmode $<
	pdflatex $<
	rm slides.log slides.aux slides.out slides.toc
	rm slides.snm slides.nav
	#rm slides.blg slides.bbl	
	#module unload texlive

slides_notesonly.pdf: slides.tex $(SLIDES_SECTIONS) $(TEX_INPUTS) $(IMG_INPUTS)
	sed 's/notes=hide/notes=only/' slides.tex  > slides_notesonly.tex
	pdflatex slides_notesonly.tex #This will fail due to natbib's bug with notes-only beamer
	rm slides_notesonly.tex slides_notesonly.log  

#INPUT RECIPES

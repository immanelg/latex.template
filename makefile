.PHONY: all watchexec clean open archive

OPENER = okular

SOURCES=$(wildcard *.tex)
PDFS=$(SOURCES:.tex=.pdf)

all: $(PDFS)

watch:
	watchexec -e tex make

%.pdf: %.tex
	latexmk -quiet -gg -use-make -interaction=nonstopmode -pdf -pdflatex="pdflatex -shell-escape" $<

open:
	@nohup $(OPENER) $(PDFS) > /dev/null 2>&1 &

clean:
	latexmk -C

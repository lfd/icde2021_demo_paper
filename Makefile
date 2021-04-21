.PHONY: all clean */*.pdf arxiv
JOB = icse2019-pasta
INPUT = main.tex
OUTPUT = build

SRC_FILES := $(wildcard *.tex)
SRC_FILES := $(filter-out graph.tex, $(SRC_FILES))

BIBLATEX = $(shell dirname $(shell kpsewhich biblatex.sty))
ARXIV = $(shell realpath ./arxiv.zip)

all: se20-merged.pdf build/$(JOB).pdf

img/graph.pdf: graph.tex
	mkdir -p $(OUTPUT)
	latexmk -lualatex -jobname=$(OUTPUT)/$(basename $^) $^
	cp -v build/$(^:.tex=.pdf) $@

arxiv: build/$(JOB).pdf
        # Add basic files
        zip $(ARXIV) $(SRC_FILES) tikz-network.sty *.csv res/* img/*

        # Add bbl file and rename it
        zip $(ARXIV) build/$(JOB).bbl
        printf "@ build/$(JOB).bbl\n@=main.bbl\n" | zipnote -w $(ARXIV)

        # We need the current version of biblatex...
        cd $(BIBLATEX) && zip $(ARXIV) ./*

clean:
        rm -rfv build img/graph.pdf icse2019-pasta.pdf arxiv.zip

.PHONY: all clean
.SUFFIXES: .md .pdf
OBJ = Proposal.pdf

all: ${OBJ}

clean: 
	rm gen/*

.md.pdf:
	pandoc $*.md --standalone \
	--bibliography $*.bib \
	-o gen/$*.pdf

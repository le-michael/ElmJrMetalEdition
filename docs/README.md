## Documents
This directory contains all documents related to the project.

### Structure
The directory structure is as follows:
- `rubrics` is where marking schemes from the course is located
- `gen` is the generated PDF output files
- All documentation will reside in the current directory level for now.

If it makes sense to split or reorganize the directory structure, then it should
be documented here.

### Compiling
#### Prerequisites
`pandoc`. Installation instructions at https://pandoc.org/installing.html
MacOS users can run `brew install pandoc`. Haskell Stack users can run
`stack install pandoc`.

`pandoc-citeproc` should also be installed for bibtex references. MacOS
users can run `brew install pandoc-citeproc`, and Haskell Stack users
can run `stack install pandoc-citeproc`.

#### Compilation
`pandoc` is a universal file converter. In this case, we convert markdown documents
into PDF output for submission.

The `Makefile` in this directory will compile all markdown files and place the output
in the `gen` directory. The workflow is:
- `make` to generate the output PDF files in `gen`.
- `make clean` to clean all PDF files.
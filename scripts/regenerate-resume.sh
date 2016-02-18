#!/bin/bash

# That means the script must be runned exclusively from the repo dir.
REPOROOT="$(git rev-parse --show-toplevel)"
SITEBIN="${REPOROOT}/dist/build/site/site"

pandoc $REPOROOT/files/resume.md \
       -o $REPOROOT/files/resume.pdf \
       --template=$REPOROOT/files/mytemplate.tex \
       --latex-engine=xelatex \
       -V mainfont="DejaVu Sans Mono" \
       -V fontsize=11pt \
       -V geometry:paperwidth=8.27in \
       -V geometry:paperheight=11.7in  \
       -V geometry:top=1in

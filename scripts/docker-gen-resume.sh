#!/bin/sh

# That means the script must be runned exclusively from the repo dir.
REPOROOT="$(git rev-parse --show-toplevel)"

docker run --volume "$REPOROOT/files:/data" --volume "/usr/share/fonts:/usr/share/fonts" --user `id -u`:`id -g` \
    pandoc/latex resume.md -o mykhailo-nedokushev.pdf \
    --template mytemplate.tex \
    --pdf-engine=xelatex \
    -V mainfont="DejaVu Sans Mono" \
    -V fontsize=11pt \
    -V geometry:paperwidth=8.27in \
    -V geometry:paperheight=11.7in  \
    -V geometry:top=1in \
    
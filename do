#!/usr/bin/bash
set -e

SOURCES=(*.tex)
OUTPUT=("${SOURCES[@]/%tex/pdf}")

LATEXMKFLAGS=(-quiet -gg -use-make -interaction=nonstopmode -pdf -pdflatex="pdflatex -shell-escape")

OPENER=okular

@all() { @build && @open
}

@build() {
    latexmk "${LATEXMKFLAGS[@]}" "${SOURCES[@]}" "$@"
}

@watch() {
    watchexec -e tex ./do build
}

@open() {
    "${OPENER}" "${OUTPUT[@]}" "$@" >/dev/null 2>&1 &disown
}

@archive() {
    rm -f *.zip
    local o="$(basename $(realpath .)).$(date +'%F-%T').zip"
    git archive HEAD -o "$o"
    zip -q "$o" "${OUTPUT[@]}"
}

@clean() {
    latexmk -C
}

##################################################################
@help() {
    echo "do™️: Do some commands for this project. Like Just, but in bash and self-contained."
    echo 
    echo "Available commands:"
    declare -F | grep "^declare -f @" | cut -f 2 -d @ | sed "s|^|\t$0 |"
}
DEFAULT=help
if [[ -z $1 ]]; then
    # this has alphabetical sorting, so we can't pick first.
    # task="$(declare -F | grep "^declare -f @" | head -n1 | cut -f 2 -d @)"
    eval "@$DEFAULT"
else
    declare -F | grep -qx "declare -f @$1" || { echo "No such task: $1"; echo; @help; exit 1; }
    task=@$1; shift
    eval "$task "$@""
fi

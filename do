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

######################################################
die() { echo "$1"; exit 1; }
if [[ -z $1 ]]; then
    task="$(declare -F | grep "^declare -f @" | head -n1 | cut -f 2 -d @)"
    eval @$task
else
    declare -F | grep -qx "declare -f @$1" || die "no task $1"
    task=@$1; shift
    eval $task "$@"
fi


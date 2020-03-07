#!/usr/bin/env bash

# Check external dependencies

#----------------------------#
# required
#----------------------------#
hash Rscript 2>/dev/null || {
    echo >&2 "R is required but it's not installed.";
    exit 1;
}

Rscript -e 'if(!require(ggplot2)){ q(status = 1) }' 2>/dev/null || {
    echo >&2 "R package ggplot2 is required but it's not installed.";
    exit 1;
}

Rscript -e 'if(!require(VennDiagram)){ q(status = 1) }' 2>/dev/null || {
    echo >&2 "R package VennDiagram is required but it's not installed.";
    exit 1;
}

Rscript -e 'if(!require(extrafont)){ q(status = 1) }' 2>/dev/null || {
    echo >&2 "R package extrafont is required but it's not installed.";
    exit 1;
}

#----------------------------#
# optional
#----------------------------#
hash pigz 2>/dev/null || {
    echo >&2 "pigz is optional but it's not installed.";
}

Rscript -e 'if(!require(doParallel)){ q(status = 1) }' 2>/dev/null || {
    echo >&2 "R package doParallel is optional but it's not installed.";
}

echo >&2 OK

exit;

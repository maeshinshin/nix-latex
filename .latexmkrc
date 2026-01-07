#!/usr/bin/env perl
# $latex = 'uplatex';
$latex = 'uplatex %O -synctex=1 -interaction=nonstopmode -shell-escape %S';
$bibtex = 'upbibtex';
$dvipdf = 'dvipdfmx %O -o %D %S';
$makeindex = 'upmendex %O -o %D %S';
$pdf_mode = 3;
$preview_mode = 0;

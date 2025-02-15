#!/bin/sh
set -x #echo on

mkdir -p ../../static
.woff2/woff2_compress FrederickatheGreat-Regular.ttf
mv FrederickatheGreat-Regular.woff2 ../../static/
.woff2/woff2_compress KodeMono.ttf
mv KodeMono.woff2 ../../static/
.woff2/woff2_compress Newsreader.ttf
mv Newsreader.woff2 ../../static/
.woff2/woff2_compress Newsreader-Italic.ttf
mv Newsreader-Italic.woff2 ../../static/
.woff2/woff2_compress SourceCodePro.ttf
mv SourceCodePro.woff2 ../../static/
.woff2/woff2_compress SourceCodePro-Italic.ttf
mv SourceCodePro-Italic.woff2 ../../static/

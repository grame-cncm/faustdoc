# Faust Quick Reference to mkdocs

This folder contains the tools to convert the latex Faust Quick Reference to mkdocs.

To generate everything:
~~~~~~~~~~
$ make
~~~~~~~~~~
or
~~~~~~~~~~
$ make all
~~~~~~~~~~


## Conversion steps

All locations are relative to the current folder


### 1 - Split the latex source into separate files

**Makefile target**: `split`  
**Input**: ../faust-quick-reference.tex  
**Output**: a set of .tmp files located in this folder  
**Tools involved**: awk  
**Scripts involved**:  
- 1 - `scripts/scan-input.awk`: scan the main latex file to inline the `\input` tags
- 2 - `scripts/split.awk`: get the inlined content as input and scan the `chapter` tags to split the input into separate files. The files are named using the current index and the `\label` tag that MUST follow the `\chapter`tag on a separate line.


### 2 - Scan the `\labels` tags to prepare internal links 

**Makefile target**: `fullrefs`  
**Input**: all .tmp files generated at step 1  
**Output**: fullrefs.sed  
**Tools involved**: grep and sed
**Scripts involved**:  
- `scripts/labels.sed`: transforms `\label`tags into a sed substitution rule, used in by the next step.


### 3 - Generates md files

**Makefile target**: `md`  
**Input**: all .tmp files generated at step 1  
**Output**: all .md files located in `../../mkdocs/docs/qreference`, all .rail files located in the rail folder  
**Tools involved**: awk, grep and sed  
**Scripts involved**:  
- scripts/tags.sed: transforms latex tags to markdown or to html classes and handle inline math. This script requires an update when new latex commands are introduced.
- scripts/tables.awk: transforms latex tables to markdown.
- scripts/rail.awk: extract rail parts to separate files. File name is provided by the makefile. Output is located in the `rail` folder.
- scripts/figures.awk: tranforms latex figures to markdown.
- scripts/listings.awk: transform `lstlisting` section to markdown.
- scripts/equations.awk: transforms `equation`to markdown.
- fullrefs.sed: transforms labels to html links using the script generated in step 2.
- scripts/cleanup.sed: cleaning phase: remove the remaining tags.


### 4 - Generates SVG diagrams from rail

**Makefile target**: `rail`  
**Input**: all .rail files generated at step 3 and found in the `rail` folder  
**Output**: all .js files located in the `../../mkdocs/docs/rail folder`  
**Tools involved**: tools/rail2js and sed  
**Scripts involved**:  
- scripts/rail.sed: transform latex special characters to md (like lbrace, dollar etc.)

Note that `tools/rail2js` has to be compiled, which is automatically done by the Makefile. The source code is located in the `tools/rail2js-src` folder.



### 5 - Styling
Simply copy the .css files located in the `css` folder to `../../mkdocs/docs/css` folder.


### 6 - Images
Copy the .png files located in the `../graph`, `../illustrations` and  `../images` folders to `../../mkdocs/docs/qreference` folder.

## Known issues
The links generated seems not to work as expected.

## Improvements

- Remove the `\label`on a separate line constrain at step 1. Requires to update `scripts/split.awk`.
- Add a "checkrail" target to verify that all rail conversions to js are properly done. Currently, errors don't stop the Makefile processing and may not be seen.
____

Any question ? Contact me: <dfober@gmail.com>





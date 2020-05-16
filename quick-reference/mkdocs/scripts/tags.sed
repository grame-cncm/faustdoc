

############## starts by removing line comments
#s/^[ 	]*%.*/__removed__/

############## unescape latex special characters
s/\\%/%/g
s/\\\$/$/g
s/\\_/_/g
s/\\&/\&/g
s/\\lowTilde/~/g
s/\\~{}/\~/g
s/\\\#/\#/
s/\\}/}/
s/\\{/{/


############## sections
s/\\subsubsection{\([^}]*\)}/#### \1/
s/\\subsection{\([^}]*\)}/### \1/
s/\\subsection.{\([^}]*\)}/### \1/
s/\\section{\([^}]*\)}/## \1/


############## handle verbatim sections
s/\\begin{verbatim}/\
~~~~~~~~~~~ faust/
s/\\end{verbatim}/~~~~~~~~~~~/


############## handle itemize sections
s/\\begin{itemize}//
s/\\end{itemize}//
s/\\item\[.\]/- /
s/\\item /- /

############## tranform specific tags
s/\\farg{\([^}]*\)}/<span class=\"roman\">_\1_<\/span>/g

s/\\faust/<span class=\"smallcaps\">Faust<\/span>/g
s/\\latex/LaTeX/g
s/\\ircam/<span class=\"smallcaps\">Ircam<\/span>/
s/\\astree/<span class=\"smallcaps\">Astree<\/span>/
s/\\svg/<span class=\"smallcaps\">Svg<\/span>/

s/\\grame/<span class=\"smallcaps\">Grame<\/span>/
s/\\cierec/<span class=\"smallcaps\">Cierec<\/span>/
s/\\ircam/<span class=\"smallcaps\">Ircam<\/span>/
s/\\ccrma/<span class=\"smallcaps\">Ccrma<\/span>/
s/\\cnmat/<span class=\"smallcaps\">Cnmat<\/span>/
s/\\create/<span class=\"smallcaps\">Create<\/span>/
s/\\mines/<span class=\"smallcaps\">Mines<\/span> ParisTech/
s/\\svg/<span class=\"smallcaps\">Svg<\/span>/g
s/\\pdf/<span class=\"smallcaps\">Pdf<\/span>/g
s/\\ie/i.e. /g
s/\\htab/  /

s/\\code{\([^}]*\)}/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline!\([^!]*\)!/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline'\([^']*\)'/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline{\([^}]*\)}/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline$\([^$]*\)$/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline|\([^|]*\)|/<span class=\"lstinline\">\1<\/span>/g
s/\\lstinline\([^!'{]\)/\1/g

s/\\myurl{\([^}]*\)}/[\1\](\1)/g


s/\\\\[ 	]*$//
#s/\\\\//


############## tranform common latex tags
s/\\marginpar{\(..*\)}/<div class=\"marginpar\">\1\
<\/div>/g
s/\\paragraph{\(..*\)}/<div class=\"paragraph\">\1<\/div> /g
s/\\textsc{\(..*\)}/<span class=\"smallcaps\">\1<\/span> /g
s/\\textbf{\([^}]*\)}/**\1**/g
s/\\bf{\([^}]*\)}/**\1**/g
s/\\textit{\([^}]*\)}/_\1_/g
s/\\texttt{\([^}]*\)}/\1/g
s/\\emph{\([^}]*\)}/**\1**/g
#s/\\mathrm{\([^}]*\)}/\1/g

s/\\url{\([^}]*\)}/[\1](\1)/g

s/\\hspace\*{[^}]*}/  /
s/\\hspace{[^}]*}/  /

############## handle inline math
s/\$\([^$]*\)\$/\\(\1\\)/g


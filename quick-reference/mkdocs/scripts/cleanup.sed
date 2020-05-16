# remove comments
s/^}[ \t]*$/__removed__/
s/.*\\begin{.*$/__removed__/
s/.*\\end{.*$/__removed__/
s/\\index{[^}*}]/__removed__/
s/\\input.*/__removed__/
s/\\printindex/__removed__/
s/\\newcommand..*$/__removed__/

s/\\label{\([^}]*\)}/<a name="\1"><\/a>/g
s/.*\\caption{.*$/__removed__/
s/.*\\includegraphics.*$/__removed__/

s/.*\\hline.*$/__removed__/

s/\\section{..*$/__removed__/g
s/\\subsection{..*$/__removed__/g
s/\\subsubsection{..*$/__removed__/g

s/\\sample{//g
s/\\bigskip//g
s/\\railalias.*$//g
s/\\smallbreak//
s/\\\\[ 	]*$//
s/\\[ 	]*$//
s/\\-//

s/<listing\([^/]*\)*\/>/\&lt;listing\1\/>/
s/<notice \/>/\&lt;notice \/>/
s/<mdoc>/\&lt;mdoc>/
s/<\/mdoc>/\&lt;\/mdoc>/
s/<equation>/\&lt;equation>/
s/<\/equation>/\&lt;\/equation>/
s/<diagram>/\&lt;diagram>/
s/<\/diagram>/\&lt;\/diagram>/
s/<metadata>/\&lt;metadata>/
s/<\/metadata>/\&lt;\/metadata>/

s/<equation>/\&lt;equation \/>/
s/<\/equation>/\&lt;\/equation \/>/

s/\\normalsize//
s/\\footnotesize//
s/\\setlength..*//

############## remove comments
s/^%.*//


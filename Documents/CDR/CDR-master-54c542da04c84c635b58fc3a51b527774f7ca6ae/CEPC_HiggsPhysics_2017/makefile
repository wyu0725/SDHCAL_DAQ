LATEX = pdflatex
BIBTEX = bibtex
DVIPS = dvips

BASENAME = CEPCHiggs2017


default: testlatex

testlatex:
	${LATEX} ${BASENAME}
	${LATEX} ${BASENAME}
	${BIBTEX} ${BASENAME}
	${BIBTEX} ${BASENAME}
	${LATEX} -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress ${BASENAME}


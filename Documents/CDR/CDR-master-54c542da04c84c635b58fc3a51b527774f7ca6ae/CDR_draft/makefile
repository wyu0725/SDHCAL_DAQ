LATEX  = pdflatex
BIBTEX = bibtex
DVIPS  = dvips

BASENAME = main_CDR 


default: CDR

clean: 
	rm -f Chapters/*.aux Chapters/*.bbl Chapters/*blg Appendices/*.aux ans*.tex *.synctex.gz *.out *.out.bak 
	rm -f main_CDR*.bbl main_CDR*.toc main_CDR*.aux main_CDR*.blg main_CDR*.dvi main_CDR*.idx main_CDR*.log main_CDR*.out  	
	rm -f      CDR*.bbl      CDR*.toc      CDR*.aux      CDR*.blg      CDR*.dvi      CDR*.idx      CDR*.log      CDR*.out  	


CDR:
	${LATEX} ${BASENAME}
	${LATEX} ${BASENAME}
	${BIBTEX} Chapters/Introduction     
	${BIBTEX} Chapters/Theory
	${BIBTEX} Chapters/ExperimentalConditions
#	${BIBTEX} Chapters/Vertex
	${BIBTEX} Chapters/SiTracker
	${BIBTEX} Chapters/TrackingSystem
	${BIBTEX} Chapters/Calorimetry
#	${BIBTEX} Chapters/Magnet
	${BIBTEX} Chapters/Muon
	${BIBTEX} Chapters/ReadoutDAQ
	${BIBTEX} Chapters/MDI
	${BIBTEX} Chapters/Performance
	${BIBTEX} Chapters/FuturePlan
#	${BIBTEX} ${BASENAME}
	${LATEX} ${BASENAME}
	${LATEX} -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress ${BASENAME}


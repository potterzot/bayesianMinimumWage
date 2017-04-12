all: clean_all data_all test output

#CLEAN
#remove any output (non-data) files
clean:
	rm -f README.md
	rm -f output/*

#remove all intermediate files, including data
clean_data:
	rm -f data/raw/* data/proc/* data/out/* output/*.pdf

clean_all: clean clean_data

#DATA
#generate new data without downloading new data
data_get: clean_data
	Rscript code/get_qcew.R

data:
	Rscript code/proc_qcew.R

data_all: data_get data

#TESTS
test:

#OUTPUT
#Project README
readme: README.Rmd
	R -e "rmarkdown::render('$(<F)')"

#Generate the paper
paper: output/paper.Rmd output/library.bib output/chicago-author-date.csl
	cd $(<D); R -e "rmarkdown::render('$(<F)', 'all')"

#Generate all the output files
output: paper readme


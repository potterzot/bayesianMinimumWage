all: clean_all data_all doc test paper readme

#CLEANING
#remove any intermediate files
clean:
	rm -f README.md

#remove all intermediate files, including data
clean_data:
	rm -f data/raw/* data/proc/* data/out/* output/*.pdf

clean_all: clean clean_data

#DATA
#generate new data without downloading new data
data_get: clean_data
	Rscript code/get_nass_qs.R all
	Rscript code/get_census.R all
	Rscript code/get_county_centroids.R

data:
	Rscript code/clean_nass.R
	Rscript code/clean_census.R
	Rscript code/combine_county_variables.R

data_all: data_get data

#TESTS
test:

#DOCUMENTATION
#document the package
doc:
	cd rpkg; R -e 'devtools::document()'


#Project README
readme: README.Rmd
	R -e "rmarkdown::render('$(<F)')"

#OUTPUT
#Generate the paper
paper: output/paper.Rmd output/library.bib output/chicago-author-date.csl
	cd $(<D); R -e "rmarkdown::render('$(<F)', 'all')"


gitbook:
	Rscript -e "bookdown::render_book('index.Rmd')"
	rm -R images

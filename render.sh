#!/bin/bash          

# render site using rmarkdown
Rscript -e 'rmarkdown::render_site()'

# render slides in extras
for slides in $( find extras -name "*slides.Rmd" ); do
  # render slides
  Rscript -e "rmarkdown::render('$slides')"
done

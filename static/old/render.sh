#!/bin/bash          

# render site using rmarkdown::render()
for file in $( find . -name "[^_]*.Rmd" -maxdepth 1 ); do
  Rscript -e "rmarkdown::render('$file')"
done

# # render slides in extras
# for slides in $( find extras -name "*slides.Rmd" ); do
#   # render slides
#   Rscript -e "rmarkdown::render('$slides')"
# done

#!/bin/bash          

# move slides to protected folder
for slides in $( find ./ -maxdepth 1 -name "*slides.Rmd" ); do
  mv $slides extras/$slides
done

# render_site using rmarkdown
Rscript -e 'rmarkdown::render_site()'

# move slides back to main directory and render
for slides in $( find extras/ -name "*slides.Rmd" ); do
  # move slides back
  filename=$(basename "$slides")
  mv extras/$filename ./$filename
  
  # rename _site.yml temporarily to properly render slides
  mv _site.yml site.yml
  
  # render slides
  Rscript -e "rmarkdown::render('$filename')"
  
  # rename _site.yml back
  mv site.yml _site.yml
done

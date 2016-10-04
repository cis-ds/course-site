#!/bin/bash          

# convert jupyter notebooks to markdown
for notebook in $( ls *.ipynb ); do
  /Users/$USER/anaconda/bin/jupyter nbconvert --to markdown $notebook
done

# copy slides to extras folder
for slides in $( find ../teach -name "*slides.html" ); do
  rsync --update $slides extras
done

# copy tutorial files to extras folder
for tutorial in $( find ../teach -name "*tutorial.html" ); do
  rsync --update $tutorial extras
done

# render_site using rmarkdown
Rscript -e 'rmarkdown::render_site()'

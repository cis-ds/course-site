#!/bin/bash          

# convert jupyter notebooks to markdown
for notebook in $( ls *.ipynb ); do
  /Users/$USER/anaconda/bin/jupyter nbconvert --to markdown $notebook
done

# render_site using rmarkdown
Rscript -e 'rmarkdown::render_site()'
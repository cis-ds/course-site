#!/bin/bash          

# convert jupyter notebooks to markdown
for notebook in $( ls *.ipynb ); do
  /Users/$USER/anaconda/bin/jupyter nbconvert --to markdown $notebook
done

# render_site using rmarkdown
## update footer
Rscript -e 'rmarkdown::render("_footer.Rmd", "html_fragment")'

## now render entire website
# Rscript -e 'rmarkdown::render_site()'
Rscript render.R FALSE
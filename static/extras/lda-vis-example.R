## lda-vis-example.R
## 6/5/19 BCS
## Reproduce the LDA visualizations from /notes/topic-models/
## without having to run the entire R Markdown file

library(tidyverse)
library(tidytext)
library(topicmodels)
library(here)
library(rjson)
library(tm)
library(LDAvis)
library(LDAvisData)

# jeopardy example
json <- createJSON(phi = Jeopardy$phi,
                   theta = Jeopardy$theta,
                   doc.length = Jeopardy$doc.length,
                   vocab = Jeopardy$vocab,
                   term.frequency = Jeopardy$term.frequency)

serVis(json)

# jokes example
topicmodels_json_ldavis <- function(fitted, doc_term){
  require(LDAvis)
  require(slam)
  
  # Find required quantities
  phi <- as.matrix(posterior(fitted)$terms)
  theta <- as.matrix(posterior(fitted)$topics)
  vocab <- colnames(phi)
  term_freq <- slam::col_sums(doc_term)
  
  # Convert to json
  json_lda <- LDAvis::createJSON(phi = phi, theta = theta,
                                 vocab = vocab,
                                 doc.length = as.vector(table(doc_term$i)),
                                 term.frequency = term_freq)
  
  return(json_lda)
}

load(file = here("static", "extras", "jokes_lda_compare.Rdata"))
jokes_100_json <- topicmodels_json_ldavis(fitted = jokes_lda_compare[[6]],
                                         doc_term = jokes_dtm)
serVis(jokes_100_json)

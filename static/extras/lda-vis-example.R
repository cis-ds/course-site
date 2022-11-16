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

load(file = here("static", "extras", "appa-lda-compare.Rdata"))
jokes_100_json <- topicmodels_json_ldavis(fitted = appa_lda_compare[[4]],
                                         doc_term = appa_dtm)
serVis(jokes_100_json)

# 6 - guy walks into a bar
# 23 - change a lightbulb
# 28 - little johnny/teacher
# 29 - die and meet st peter
# 39 - genie and 3 wishes
# 45 - doctor/knock knock
# 49 - chicken crossed the road
# 97 - yo mama





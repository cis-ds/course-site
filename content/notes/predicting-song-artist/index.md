---
title: "Predicting song artist from lyrics"
date: 2019-03-01

type: docs
toc: true
draft: false
categories: ["text"]

menu:
  notes:
    parent: Text analysis
    weight: 5
---




```r
library(tidyverse)
library(tidymodels)
library(stringr)
library(textrecipes)
library(themis)
library(vip)

set.seed(123)
theme_set(theme_minimal())
```

{{% callout note %}}

Run the code below in your console to download this exercise as a set of R scripts.

```r
usethis::use_course("uc-cfss/text-analysis-classification-and-topic-modeling")
```

{{% /callout %}}

{{< figure src="beyonce-taylor-swift.jpeg" caption="Beyoncé and Taylor Swift at the 2009 MTV Video Music Awards." >}}

Beyoncé and Taylor Swift are two iconic singer/songwriters from the past twenty years. While they have achieved worldwide recognition for their contributions to music, they also have quite diverse musical genres and themes. For example, much of Taylor Swift's early work is commonly associated with [love and heartbreak](https://en.wikipedia.org/wiki/Taylor_Swift#Songwriting), while Beyoncé's career has been noted for many compositions surrounding [female-empowerment](https://en.wikipedia.org/wiki/Beyonc%C3%A9#Songwriting). Based purely on the lyrics, can we predict if a song is by Beyoncé or Taylor Swift?

## Import data

Our data comes from [#TidyTuesday](https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-09-29) which compiled individual song lyrics from each singer's discography as of September 29, 2020. Here we import the data files and do some light cleaning to standardize each file.^[Importantly, the Beyoncé lyrics are originally stored as one row per line per song whereas we need them stored as one row per song for modeling purposes.]


```r
# get beyonce and taylor swift lyrics
beyonce_lyrics <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/beyonce_lyrics.csv")
```

```
## Rows: 22616 Columns: 6
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (3): line, song_name, artist_name
## dbl (3): song_id, artist_id, song_line
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

```r
taylor_swift_lyrics <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-29/taylor_swift_lyrics.csv")
```

```
## Rows: 132 Columns: 4
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (4): Artist, Album, Title, Lyrics
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

```r
# clean lyrics for binding
beyonce_clean <- beyonce_lyrics %>%
  # convert to one row per song
  group_by(song_id, song_name, artist_name) %>%
  summarize(Lyrics = str_flatten(line, collapse = " ")) %>%
  ungroup() %>%
  # clean column names
  select(artist = artist_name, song_title = song_name, lyrics = Lyrics)
```

```
## `summarise()` has grouped output by 'song_id', 'song_name'. You can override using the `.groups` argument.
```

```r
taylor_swift_clean <- taylor_swift_lyrics %>%
  # clean column names
  select(artist = Artist, song_title = Title, lyrics = Lyrics)

# combine into single data file
lyrics <- bind_rows(beyonce_clean, taylor_swift_clean) %>%
  mutate(artist = factor(artist))
lyrics
```

```
## # A tibble: 523 × 3
##    artist  song_title                         lyrics                            
##    <fct>   <chr>                              <chr>                             
##  1 Beyoncé Ego (Remix) (Ft. Kanye West)       "I got a big ego (Ha ha ha) I’m s…
##  2 Beyoncé Irreplaceable (Rap Version) (Ft. … "To the left To the left To the l…
##  3 Beyoncé Smash Into You                     "Head down As I watch my feet tak…
##  4 Beyoncé Cards Never Lie (Ft. Rah Digga & … "The cards never lie, my last bre…
##  5 Beyoncé If Looks Could Kill (You Would Be… "Sweetness flowing like a faucet,…
##  6 Beyoncé The Last Great Seduction (Ft. Mek… "You know you really, really, rea…
##  7 Beyoncé Check on It (LP Version) (Ft. Sli… "Swizz Beatz DC, Destiny Child (S…
##  8 Beyoncé Crazy in Love (Ft. JAY-Z)          "Yes! So crazy right now! Most in…
##  9 Beyoncé Déjà Vu (Ft. JAY-Z)                "Bass (Uh) Hi-hat (Uh) 808 (Uh) J…
## 10 Beyoncé Me, Myself & I (Remix) (Ft. Ghost… "Ahh, ahh, ahh all the ladies if …
## # … with 513 more rows
```

## Preprocess the dataset for modeling

### Resampling folds

- Split the data into training/test sets with 75% allocated for training
- Split the training set into 10 cross-validation folds

{{< spoiler text="Click for the solution" >}}

[`rsample`](/notes/resampling/) is the go-to package for this resampling.


```r
# split into training/testing
set.seed(123)
lyrics_split <- initial_split(data = lyrics, strata = artist, prop = 0.75)

lyrics_train <- training(lyrics_split)
lyrics_test <- testing(lyrics_split)

# create cross-validation folds
lyrics_folds <- vfold_cv(data = lyrics_train, strata = artist)
```

{{< /spoiler >}}

### Define the feature engineering recipe

- Define a feature engineering recipe to predict the song's artist as a function of the lyrics
- Tokenize the song lyrics
- Remove stop words
- Only keep the 500 most frequently appearing tokens
- Calculate tf-idf scores for the remaining tokens
    - This will generate one column for every token. Each column will have the standardized name `tfidf_lyrics_*` where `*` is the specific token. Instead we would prefer the column names simply be `*`. You can remove the `tfidf_lyrics_` prefix using
    
        ```r
        # Simplify these names
        step_rename_at(starts_with("tfidf_lyrics_"),
          fn = ~ str_replace_all(
            string = .,
            pattern = "tfidf_lyrics_",
            replacement = ""
          )
        )
        ```
        
- [Downsample](/notes/supervised-text-classification/#concerns-regarding-multiclass-classification) the observations so there are an equal number of songs by Beyoncé and Taylor Swift in the analysis set

{{< spoiler text="Click for the solution" >}}


```r
# define preprocessing recipe
lyrics_rec <- recipe(artist ~ lyrics, data = lyrics_train) %>%
  step_tokenize(lyrics) %>%
  step_stopwords(lyrics) %>%
  step_tokenfilter(lyrics, max_tokens = 500) %>%
  step_tfidf(lyrics) %>%
  # Simplify these names
  step_rename_at(starts_with("tfidf_lyrics_"),
    fn = ~ str_replace_all(
      string = .,
      pattern = "tfidf_lyrics_",
      replacement = ""
    )
  ) %>%
  step_downsample(artist)
lyrics_rec
```

```
## Recipe
## 
## Inputs:
## 
##       role #variables
##    outcome          1
##  predictor          1
## 
## Operations:
## 
## Tokenization for lyrics
## Stop word removal for lyrics
## Text filtering for lyrics
## Term frequency-inverse document frequency with lyrics
## Variable renaming for starts_with("tfidf_lyrics_")
## Down-sampling based on artist
```

{{< /spoiler >}}

## Estimate a random forest model

- Define a random forest model grown with 1000 trees using the `ranger` engine.
- Define a workflow using the feature engineering recipe and random forest model specification. Fit the workflow using the cross-validation folds.
    - Use `control = control_resamples(save_pred = TRUE)` to save the assessment set predictions. We need these to assess the model's performance.
    
{{< spoiler text="Click for the solution" >}}


```r
# define the model specification
ranger_spec <- rand_forest(trees = 1000) %>%
  set_mode("classification") %>%
  set_engine("ranger")

# define the workflow
ranger_workflow <- workflow() %>%
  add_recipe(lyrics_rec) %>%
  add_model(ranger_spec)

# fit the model to each of the cross-validation folds
ranger_cv <- ranger_workflow %>%
  fit_resamples(
    resamples = lyrics_folds,
    control = control_resamples(save_pred = TRUE)
  )
```

{{< /spoiler >}}

### Evaluate model performance

- Calculate the model's accuracy and ROC AUC. How did it perform?
- Draw the ROC curve for each validation fold
- Generate the resampled confusion matrix for the model and draw it using a heatmap. How does the model perform predicting Beyoncé songs relative to Taylor Swift songs?

{{< spoiler text="Click for the solution" >}}


```r
# extract metrics and predictions
ranger_cv_metrics <- collect_metrics(ranger_cv)
ranger_cv_predictions <- collect_predictions(ranger_cv)

# how well did the model perform?
ranger_cv_metrics
```

```
## # A tibble: 2 × 6
##   .metric  .estimator  mean     n std_err .config             
##   <chr>    <chr>      <dbl> <int>   <dbl> <chr>               
## 1 accuracy binary     0.832    10  0.0226 Preprocessor1_Model1
## 2 roc_auc  binary     0.949    10  0.0104 Preprocessor1_Model1
```

```r
# roc curve
ranger_cv_predictions %>%
  group_by(id) %>%
  roc_curve(truth = artist, .pred_Beyoncé) %>%
  autoplot()
```

<img src="{{< blogdown/postref >}}index_files/figure-html/ranger-metrics-1.png" width="672" />

```r
# confusion matrix
conf_mat_resampled(x = ranger_cv, tidy = FALSE) %>%
  autoplot(type = "heatmap")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/ranger-metrics-2.png" width="672" />

Overall the random forest model is reasonable at distinguishing Beyoncé from Taylor Swift based purely on the lyrics. A ROC AUC value of 0.9491533 is pretty good for a binary classification task. We can also see the model more accurately predicts Beyoncé's songs compared to Taylor Swift. Part of this is because Beyoncé's catalog is much larger (391 songs compared to only 132 for Taylor Swift), but this should have been accounted for through the downsampling. Even after this procedure, the model still has better sensitivity to Beyoncé.

{{< /spoiler >}}

## Penalized regression

## Define the feature engineering recipe

Define the same feature engineering recipe as before, with two adjustments:

1. Calculate all possible 1-grams, 2-grams, 3-grams, 4-grams, and 5-grams
1. Retain the 2000 most frequently occurring tokens.

{{< spoiler text="Click for the solution" >}}


```r
# redefine recipe to include multiple n-grams
glmnet_rec <- recipe(artist ~ lyrics, data = lyrics_train) %>%
  step_tokenize(lyrics) %>%
  step_stopwords(lyrics) %>%
  step_ngram(lyrics, num_tokens = 5L, min_num_tokens = 1L) %>%
  step_tokenfilter(lyrics, max_tokens = 2000) %>%
  step_tfidf(lyrics) %>%
  # Simplify these names
  step_rename_at(starts_with("tfidf_lyrics_"),
    fn = ~ str_replace_all(string = ., pattern = "tfidf_lyrics_", replacement = "")
  ) %>%
  step_downsample(artist)
glmnet_rec
```

```
## Recipe
## 
## Inputs:
## 
##       role #variables
##    outcome          1
##  predictor          1
## 
## Operations:
## 
## Tokenization for lyrics
## Stop word removal for lyrics
## ngramming for lyrics
## Text filtering for lyrics
## Term frequency-inverse document frequency with lyrics
## Variable renaming for starts_with("tfidf_lyrics_")
## Down-sampling based on artist
```

{{< /spoiler >}}

### Tune the penalized regression model

- Define the penalized regression model specification, including tuning placeholders for `penalty` and `mixture`
- Create the workflow object
- Define a tuning grid with every combination of:
    - `penalty = 10^seq(-6, -1, length.out = 20)`
    - `mixture = c(0, 0.2, 0.4, 0.6, 0.8, 1)`
- Tune the model using the cross-validation folds
- Evaluate the tuning procedure and identify the best performing models based on ROC AUC

{{< spoiler text="Click for the solution" >}}


```r
# define the penalized regression model specification
glmnet_spec <- logistic_reg(penalty = tune(), mixture = tune()) %>%
  set_mode("classification") %>%
  set_engine("glmnet")

# define the new workflow
glmnet_workflow <- workflow() %>%
  add_recipe(glmnet_rec) %>%
  add_model(glmnet_spec)

# create the tuning grid
glmnet_grid <- tidyr::crossing(
  penalty = 10^seq(-6, -1, length.out = 20),
  mixture = c(0, 0.2, 0.4, 0.6, 0.8, 1)
)

# tune over the model hyperparameters
glmnet_tune <- tune_grid(
  object = glmnet_workflow,
  resamples = lyrics_folds,
  grid = glmnet_grid
)
```


```r
# evaluate results
collect_metrics(x = glmnet_tune)
```

```
## # A tibble: 240 × 8
##       penalty mixture .metric  .estimator  mean     n std_err .config           
##         <dbl>   <dbl> <chr>    <chr>      <dbl> <int>   <dbl> <chr>             
##  1 0.000001         0 accuracy binary     0.753    10  0.0255 Preprocessor1_Mod…
##  2 0.000001         0 roc_auc  binary     0.884    10  0.0268 Preprocessor1_Mod…
##  3 0.00000183       0 accuracy binary     0.753    10  0.0255 Preprocessor1_Mod…
##  4 0.00000183       0 roc_auc  binary     0.884    10  0.0268 Preprocessor1_Mod…
##  5 0.00000336       0 accuracy binary     0.753    10  0.0255 Preprocessor1_Mod…
##  6 0.00000336       0 roc_auc  binary     0.884    10  0.0268 Preprocessor1_Mod…
##  7 0.00000616       0 accuracy binary     0.753    10  0.0255 Preprocessor1_Mod…
##  8 0.00000616       0 roc_auc  binary     0.884    10  0.0268 Preprocessor1_Mod…
##  9 0.0000113        0 accuracy binary     0.753    10  0.0255 Preprocessor1_Mod…
## 10 0.0000113        0 roc_auc  binary     0.884    10  0.0268 Preprocessor1_Mod…
## # … with 230 more rows
```

```r
autoplot(glmnet_tune)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/glmnet-metrics-1.png" width="672" />

```r
# identify the five best hyperparameter combinations
show_best(x = glmnet_tune, metric = "roc_auc")
```

```
## # A tibble: 5 × 8
##      penalty mixture .metric .estimator  mean     n std_err .config             
##        <dbl>   <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
## 1 0.000001         0 roc_auc binary     0.884    10  0.0268 Preprocessor1_Model…
## 2 0.00000183       0 roc_auc binary     0.884    10  0.0268 Preprocessor1_Model…
## 3 0.00000336       0 roc_auc binary     0.884    10  0.0268 Preprocessor1_Model…
## 4 0.00000616       0 roc_auc binary     0.884    10  0.0268 Preprocessor1_Model…
## 5 0.0000113        0 roc_auc binary     0.884    10  0.0268 Preprocessor1_Model…
```

Based on the ROC AUC, any penalty parameter with a mixture of `0` provides the optimal model performance. Though compared to the random forest model, the penalized regression approach consistently generates lower ROC AUC scores. This is likely because penalized regression models are a form of generalized linear models which assume linear, additive relationships between the predictors (i.e. n-grams) and the outcome of interest. Random forests are built from decision trees which are highly interactive and non-linear, so they allow for more flexible relationships between the predictors and outcome.

{{< /spoiler >}}

### Fit the best model

- Select the hyperparameter combinations that achieve the highest ROC AUC
- Fit the penalized regression model using the best hyperparameters and the full training set. How well does the model perform on the test set?

{{< spoiler text="Click for the solution" >}}


```r
# select the best model's hyperparameters
glmnet_best <- select_best(glmnet_tune, metric = "roc_auc")

# fit a single model using the selected hyperparameters and the full training set
glmnet_final <- glmnet_workflow %>%
  finalize_workflow(parameters = glmnet_best) %>%
  last_fit(split = lyrics_split)
collect_metrics(glmnet_final)
```

```
## # A tibble: 2 × 4
##   .metric  .estimator .estimate .config             
##   <chr>    <chr>          <dbl> <chr>               
## 1 accuracy binary         0.779 Preprocessor1_Model1
## 2 roc_auc  binary         0.859 Preprocessor1_Model1
```

Not surprisingly the test set performance is slightly lower than the cross-validated metrics, however it still offers decent performance.

0.8593074

{{< /spoiler >}}

### Variable importance

Beyond predictive power, we can analyze which n-grams contribute most strongly to the model's predictions. Here we use the [`vip`](https://koalaverse.github.io/vip/index.html) and `vi()` to calculate the importance score for each n-gram, then visualize them using a bar plot.


```r
# extract parnsip model fit
glmnet_imp <- extract_fit_parsnip(glmnet_final) %>%
  # calculate variable importance for the specific penalty parameter used
  vi(lambda = glmnet_best$penalty)

# clean up the data frame for visualization
glmnet_imp %>%
  mutate(
    Sign = case_when(
      Sign == "POS" ~ "More likely from Beyoncé",
      Sign == "NEG" ~ "More likely from Taylor Swift"
    ),
    Importance = abs(Importance)
  ) %>%
  group_by(Sign) %>%
  # extract 20 most important n-grams for each artist
  slice_max(order_by = Importance, n = 20) %>%
  ggplot(mapping = aes(
    x = Importance,
    y = fct_reorder(Variable, Importance),
    fill = Sign
  )) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_fill_brewer(type = "qual") +
  facet_wrap(facets = vars(Sign), scales = "free") +
  labs(
    y = NULL,
    title = "Variable importance for predicting the song artist",
    subtitle = "These features are the most important in predicting\nwhether a song is by Beyoncé or Taylor Swift"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/glmnet-vip-1.png" width="672" />

This helps provide facial validity for the model's predictions. Not surprisingly, most of the n-grams relevant to Taylor Swift involve "love" and "baby", whereas "girls girls" is likely generalized from "Run the World (Girls)".

{{< youtube id="VBmMU_iwe6U" title="Beyoncé - Run the World (Girls) (Official Video)" >}}

## Acknowledgments

- Exercise inspired by the [#TidyTuesday challenge on September 29, 2020](https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-09-29).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.1.2 (2021-11-01)
##  os       macOS Monterey 12.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       America/Chicago
##  date     2022-01-18
##  pandoc   2.14.2 @ /usr/local/bin/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package      * version    date (UTC) lib source
##  assertthat     0.2.1      2019-03-21 [1] CRAN (R 4.1.0)
##  backports      1.4.1      2021-12-13 [1] CRAN (R 4.1.1)
##  BBmisc         1.11       2017-03-10 [1] CRAN (R 4.1.0)
##  blogdown       1.7        2021-12-19 [1] CRAN (R 4.1.1)
##  bookdown       0.24       2021-09-02 [1] CRAN (R 4.1.1)
##  broom        * 0.7.11     2022-01-03 [1] CRAN (R 4.1.2)
##  bslib          0.3.1      2021-10-06 [1] CRAN (R 4.1.1)
##  cachem         1.0.6      2021-08-19 [1] CRAN (R 4.1.1)
##  callr          3.7.0      2021-04-20 [1] CRAN (R 4.1.0)
##  cellranger     1.1.0      2016-07-27 [1] CRAN (R 4.1.0)
##  checkmate      2.0.0      2020-02-06 [1] CRAN (R 4.1.1)
##  class          7.3-19     2021-05-03 [1] CRAN (R 4.1.2)
##  cli            3.1.0      2021-10-27 [1] CRAN (R 4.1.1)
##  codetools      0.2-18     2020-11-04 [1] CRAN (R 4.1.2)
##  colorspace     2.0-2      2021-06-24 [1] CRAN (R 4.1.1)
##  crayon         1.4.2      2021-10-29 [1] CRAN (R 4.1.1)
##  data.table     1.14.2     2021-09-27 [1] CRAN (R 4.1.1)
##  DBI            1.1.2      2021-12-20 [1] CRAN (R 4.1.1)
##  dbplyr         2.1.1      2021-04-06 [1] CRAN (R 4.1.0)
##  desc           1.4.0      2021-09-28 [1] CRAN (R 4.1.1)
##  devtools       2.4.3      2021-11-30 [1] CRAN (R 4.1.1)
##  dials        * 0.0.10     2021-09-10 [1] CRAN (R 4.1.1)
##  DiceDesign     1.9        2021-02-13 [1] CRAN (R 4.1.0)
##  digest         0.6.29     2021-12-01 [1] CRAN (R 4.1.1)
##  doParallel     1.0.16     2020-10-16 [1] CRAN (R 4.1.0)
##  dplyr        * 1.0.7      2021-06-18 [1] CRAN (R 4.1.0)
##  ellipsis       0.3.2      2021-04-29 [1] CRAN (R 4.1.0)
##  evaluate       0.14       2019-05-28 [1] CRAN (R 4.1.0)
##  fansi          0.5.0      2021-05-25 [1] CRAN (R 4.1.0)
##  fastmap        1.1.0      2021-01-25 [1] CRAN (R 4.1.0)
##  fastmatch      1.1-3      2021-07-23 [1] CRAN (R 4.1.0)
##  FNN            1.1.3      2019-02-15 [1] CRAN (R 4.1.0)
##  forcats      * 0.5.1      2021-01-27 [1] CRAN (R 4.1.1)
##  foreach        1.5.1      2020-10-15 [1] CRAN (R 4.1.0)
##  fs             1.5.2      2021-12-08 [1] CRAN (R 4.1.1)
##  furrr          0.2.3      2021-06-25 [1] CRAN (R 4.1.0)
##  future         1.23.0     2021-10-31 [1] CRAN (R 4.1.1)
##  future.apply   1.8.1      2021-08-10 [1] CRAN (R 4.1.1)
##  generics       0.1.1      2021-10-25 [1] CRAN (R 4.1.1)
##  ggplot2      * 3.3.5      2021-06-25 [1] CRAN (R 4.1.1)
##  globals        0.14.0     2020-11-22 [1] CRAN (R 4.1.0)
##  glue           1.6.0      2021-12-17 [1] CRAN (R 4.1.1)
##  gower          0.2.2      2020-06-23 [1] CRAN (R 4.1.0)
##  GPfit          1.0-8      2019-02-08 [1] CRAN (R 4.1.0)
##  gridExtra      2.3        2017-09-09 [1] CRAN (R 4.1.1)
##  gtable         0.3.0      2019-03-25 [1] CRAN (R 4.1.1)
##  hardhat        0.1.6      2021-07-14 [1] CRAN (R 4.1.0)
##  haven          2.4.3      2021-08-04 [1] CRAN (R 4.1.1)
##  here           1.0.1      2020-12-13 [1] CRAN (R 4.1.0)
##  hms            1.1.1      2021-09-26 [1] CRAN (R 4.1.1)
##  htmltools      0.5.2      2021-08-25 [1] CRAN (R 4.1.1)
##  httr           1.4.2      2020-07-20 [1] CRAN (R 4.1.0)
##  infer        * 1.0.0      2021-08-13 [1] CRAN (R 4.1.1)
##  ipred          0.9-12     2021-09-15 [1] CRAN (R 4.1.1)
##  iterators      1.0.13     2020-10-15 [1] CRAN (R 4.1.0)
##  jquerylib      0.1.4      2021-04-26 [1] CRAN (R 4.1.0)
##  jsonlite       1.7.2      2020-12-09 [1] CRAN (R 4.1.0)
##  knitr          1.37       2021-12-16 [1] CRAN (R 4.1.1)
##  lattice        0.20-45    2021-09-22 [1] CRAN (R 4.1.2)
##  lava           1.6.10     2021-09-02 [1] CRAN (R 4.1.1)
##  lhs            1.1.3      2021-09-08 [1] CRAN (R 4.1.1)
##  lifecycle      1.0.1      2021-09-24 [1] CRAN (R 4.1.1)
##  listenv        0.8.0      2019-12-05 [1] CRAN (R 4.1.0)
##  lubridate      1.8.0      2021-10-07 [1] CRAN (R 4.1.1)
##  magrittr       2.0.1      2020-11-17 [1] CRAN (R 4.1.0)
##  MASS           7.3-54     2021-05-03 [1] CRAN (R 4.1.0)
##  Matrix         1.3-4      2021-06-01 [1] CRAN (R 4.1.2)
##  memoise        2.0.1      2021-11-26 [1] CRAN (R 4.1.1)
##  mlr            2.19.0     2021-02-22 [1] CRAN (R 4.1.0)
##  modeldata    * 0.1.1      2021-07-14 [1] CRAN (R 4.1.0)
##  modelr         0.1.8      2020-05-19 [1] CRAN (R 4.1.0)
##  munsell        0.5.0      2018-06-12 [1] CRAN (R 4.1.0)
##  nnet           7.3-16     2021-05-03 [1] CRAN (R 4.1.2)
##  parallelly     1.30.0     2021-12-17 [1] CRAN (R 4.1.1)
##  parallelMap    1.5.1      2021-06-28 [1] CRAN (R 4.1.0)
##  ParamHelpers   1.14       2020-03-24 [1] CRAN (R 4.1.0)
##  parsnip      * 0.1.7      2021-07-21 [1] CRAN (R 4.1.0)
##  pillar         1.6.4      2021-10-18 [1] CRAN (R 4.1.1)
##  pkgbuild       1.3.1      2021-12-20 [1] CRAN (R 4.1.1)
##  pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.1.0)
##  pkgload        1.2.4      2021-11-30 [1] CRAN (R 4.1.1)
##  plyr           1.8.6      2020-03-03 [1] CRAN (R 4.1.0)
##  prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.1.0)
##  pROC           1.18.0     2021-09-03 [1] CRAN (R 4.1.1)
##  processx       3.5.2      2021-04-30 [1] CRAN (R 4.1.0)
##  prodlim        2019.11.13 2019-11-17 [1] CRAN (R 4.1.0)
##  ps             1.6.0      2021-02-28 [1] CRAN (R 4.1.0)
##  purrr        * 0.3.4      2020-04-17 [1] CRAN (R 4.1.0)
##  R6             2.5.1      2021-08-19 [1] CRAN (R 4.1.1)
##  RANN           2.6.1      2019-01-08 [1] CRAN (R 4.1.0)
##  Rcpp           1.0.7      2021-07-07 [1] CRAN (R 4.1.0)
##  readr        * 2.1.1      2021-11-30 [1] CRAN (R 4.1.1)
##  readxl         1.3.1      2019-03-13 [1] CRAN (R 4.1.0)
##  recipes      * 0.1.17     2021-09-27 [1] CRAN (R 4.1.1)
##  remotes        2.4.2      2021-11-30 [1] CRAN (R 4.1.1)
##  reprex         2.0.1      2021-08-05 [1] CRAN (R 4.1.1)
##  rlang          0.4.12     2021-10-18 [1] CRAN (R 4.1.1)
##  rmarkdown      2.11       2021-09-14 [1] CRAN (R 4.1.1)
##  ROSE           0.0-4      2021-06-14 [1] CRAN (R 4.1.0)
##  rpart          4.1-15     2019-04-12 [1] CRAN (R 4.1.0)
##  rprojroot      2.0.2      2020-11-15 [1] CRAN (R 4.1.0)
##  rsample      * 0.1.1      2021-11-08 [1] CRAN (R 4.1.1)
##  rstudioapi     0.13       2020-11-12 [1] CRAN (R 4.1.0)
##  rvest          1.0.2      2021-10-16 [1] CRAN (R 4.1.1)
##  sass           0.4.0      2021-05-12 [1] CRAN (R 4.1.0)
##  scales       * 1.1.1      2020-05-11 [1] CRAN (R 4.1.0)
##  sessioninfo    1.2.2      2021-12-06 [1] CRAN (R 4.1.1)
##  SnowballC      0.7.0      2020-04-01 [1] CRAN (R 4.1.0)
##  stringi        1.7.6      2021-11-29 [1] CRAN (R 4.1.1)
##  stringr      * 1.4.0      2019-02-10 [1] CRAN (R 4.1.1)
##  survival       3.2-13     2021-08-24 [1] CRAN (R 4.1.2)
##  testthat       3.1.1      2021-12-03 [1] CRAN (R 4.1.1)
##  textrecipes  * 0.4.1      2021-07-11 [1] CRAN (R 4.1.0)
##  themis       * 0.1.4      2021-06-12 [1] CRAN (R 4.1.0)
##  tibble       * 3.1.6      2021-11-07 [1] CRAN (R 4.1.1)
##  tidymodels   * 0.1.4      2021-10-01 [1] CRAN (R 4.1.1)
##  tidyr        * 1.1.4      2021-09-27 [1] CRAN (R 4.1.1)
##  tidyselect     1.1.1      2021-04-30 [1] CRAN (R 4.1.0)
##  tidyverse    * 1.3.1      2021-04-15 [1] CRAN (R 4.1.0)
##  timeDate       3043.102   2018-02-21 [1] CRAN (R 4.1.0)
##  tokenizers     0.2.1      2018-03-29 [1] CRAN (R 4.1.0)
##  tune         * 0.1.6      2021-07-21 [1] CRAN (R 4.1.0)
##  tzdb           0.2.0      2021-10-27 [1] CRAN (R 4.1.1)
##  unbalanced     2.0        2015-06-26 [1] CRAN (R 4.1.0)
##  usethis        2.1.5      2021-12-09 [1] CRAN (R 4.1.1)
##  utf8           1.2.2      2021-07-24 [1] CRAN (R 4.1.0)
##  vctrs          0.3.8      2021-04-29 [1] CRAN (R 4.1.0)
##  vip          * 0.3.2      2020-12-17 [1] CRAN (R 4.1.0)
##  withr          2.4.3      2021-11-30 [1] CRAN (R 4.1.1)
##  workflows    * 0.2.4      2021-10-12 [1] CRAN (R 4.1.1)
##  workflowsets * 0.1.0      2021-07-22 [1] CRAN (R 4.1.1)
##  xfun           0.29       2021-12-14 [1] CRAN (R 4.1.1)
##  xml2           1.3.3      2021-11-30 [1] CRAN (R 4.1.1)
##  yaml           2.2.1      2020-02-01 [1] CRAN (R 4.1.0)
##  yardstick    * 0.0.9      2021-11-22 [1] CRAN (R 4.1.1)
## 
##  [1] /Library/Frameworks/R.framework/Versions/4.1-arm64/Resources/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```

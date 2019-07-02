---
title: "Relational data: a quick review"
date: 2019-03-01

type: docs
toc: true
draft: false
aliases: ["/datawrangle_relational_data.html"]
categories: ["datawrangle"]

menu:
  notes:
    parent: Data wrangling
    weight: 4
---



**Relational data** is multiple tables of data that when combined together answer research questions. Relations define the important element, not just the individual tables. Relations are defined between a pair of tables, or potentially complex structures can be built up with more than 2 tables. In many situations, data is stored in a relational format because to do otherwise would introduce redundancy and use unnecessary storage space.

This data structure requires **relational verbs** to combine data across tables. **Mutating joins** add new variables to one data frame from matching observations in another, whereas **filtering joins** filter observations from one data frame based on whether or not they match an observation in the other table.

## `superheroes` and `publishers`

Let's review how these different types of joining operations work with relational data on comic books. Load the `rcfss` library. There are two data frames which contain data on comic books.


```r
library(tidyverse)
library(rcfss)

superheroes
```

```
## # A tibble: 7 x 4
##   name     alignment gender publisher    
##   <chr>    <chr>     <chr>  <chr>        
## 1 Magneto  bad       male   Marvel       
## 2 Storm    good      female Marvel       
## 3 Mystique bad       female Marvel       
## 4 Batman   good      male   DC           
## 5 Joker    bad       male   DC           
## 6 Catwoman bad       female DC           
## 7 Sabrina  good      female Archie Comics
```

```r
publishers
```

```
## # A tibble: 3 x 2
##   publisher yr_founded
##   <chr>          <dbl>
## 1 DC              1934
## 2 Marvel          1939
## 3 Image           1992
```

Would it make sense to store these two data frames in the same tibble? **No!** This is because each data frame contains substantively different information:

* `superheroes` contains data on superheroes
* `publishers` contains data on publishers

The units of analysis are completely different. Just as it made sense to split [Minard's data into two separate data frames](/notes/minard/), it also makes sense to store them separately here. That said, depending on the type of analysis you seek to perform, it makes sense to join the data frames together temporarily. How should we join them? Well it depends on how you plan to ask your question. Let's look at the result of several different join operations.



## Mutating joins

## Inner join

> `inner_join(x, y)`: Return all rows from `x` where there are matching values in `y`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.


```r
(ijsp <- inner_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 6 x 5
##   name     alignment gender publisher yr_founded
##   <chr>    <chr>     <chr>  <chr>          <dbl>
## 1 Magneto  bad       male   Marvel          1939
## 2 Storm    good      female Marvel          1939
## 3 Mystique bad       female Marvel          1939
## 4 Batman   good      male   DC              1934
## 5 Joker    bad       male   DC              1934
## 6 Catwoman bad       female DC              1934
```

We lose Sabrina in the join because, although she appears in `x = superheroes`, her publisher Archie Comics does not appear in `y = publishers`. The join result has all variables from `x = superheroes` plus `yr_founded`, from `y`.



<table border = 1>
<tr>
<td valign="top">

  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
<td valign="top">

  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">

  `inner_join(x = superheroes, y = publishers)`
  
  

|name     |alignment |gender |publisher | yr_founded|
|:--------|:---------|:------|:---------|----------:|
|Magneto  |bad       |male   |Marvel    |       1939|
|Storm    |good      |female |Marvel    |       1939|
|Mystique |bad       |female |Marvel    |       1939|
|Batman   |good      |male   |DC        |       1934|
|Joker    |bad       |male   |DC        |       1934|
|Catwoman |bad       |female |DC        |       1934|


  
</td>
</tr>
</table>
  
## Left join

> `left_join(x, y)`: Return all rows from `x`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.


```r
(ljsp <- left_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 7 x 5
##   name     alignment gender publisher     yr_founded
##   <chr>    <chr>     <chr>  <chr>              <dbl>
## 1 Magneto  bad       male   Marvel              1939
## 2 Storm    good      female Marvel              1939
## 3 Mystique bad       female Marvel              1939
## 4 Batman   good      male   DC                  1934
## 5 Joker    bad       male   DC                  1934
## 6 Catwoman bad       female DC                  1934
## 7 Sabrina  good      female Archie Comics         NA
```

We basically get `x = superheroes` back, but with the addition of variable `yr_founded`, which is unique to `y = publishers`. Sabrina, whose publisher does not appear in `y = publishers`, has an `NA` for `yr_founded`.



<table border = 1>
  <tr>
  <td valign="top">
  
  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
  <td valign="top">
  
  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">

  `left_join(x = superheroes, y = publishers)`
  
  

|name     |alignment |gender |publisher     | yr_founded|
|:--------|:---------|:------|:-------------|----------:|
|Magneto  |bad       |male   |Marvel        |       1939|
|Storm    |good      |female |Marvel        |       1939|
|Mystique |bad       |female |Marvel        |       1939|
|Batman   |good      |male   |DC            |       1934|
|Joker    |bad       |male   |DC            |       1934|
|Catwoman |bad       |female |DC            |       1934|
|Sabrina  |good      |female |Archie Comics |         NA|


  
</td>
</tr>
</table>

## Right join

> `right_join(x, y)`: Return all rows from `y`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.


```r
(rjsp <- right_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 7 x 5
##   name     alignment gender publisher yr_founded
##   <chr>    <chr>     <chr>  <chr>          <dbl>
## 1 Batman   good      male   DC              1934
## 2 Joker    bad       male   DC              1934
## 3 Catwoman bad       female DC              1934
## 4 Magneto  bad       male   Marvel          1939
## 5 Storm    good      female Marvel          1939
## 6 Mystique bad       female Marvel          1939
## 7 <NA>     <NA>      <NA>   Image           1992
```

We basically get `y = publishers` back, but with the addition of variables `name`, `alignment`, and `gender`, which is unique to `x = superheroes`. Image, who did not publish any of the characters in `superheroes`, has an `NA` for the new variables.

We could also accomplish virtually the same thing using `left_join()` by reversing the order of the data frames in the function:


```r
left_join(x = superheroes, y = publishers)
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 7 x 5
##   name     alignment gender publisher     yr_founded
##   <chr>    <chr>     <chr>  <chr>              <dbl>
## 1 Magneto  bad       male   Marvel              1939
## 2 Storm    good      female Marvel              1939
## 3 Mystique bad       female Marvel              1939
## 4 Batman   good      male   DC                  1934
## 5 Joker    bad       male   DC                  1934
## 6 Catwoman bad       female DC                  1934
## 7 Sabrina  good      female Archie Comics         NA
```

Doing so returns the same basic data frame, with the column orders reversed. `right_join()` is not used as commonly as `left_join()`, but works well in a piped operation when you perform several functions on `x` but then want to join it with `y` and only keep rows that appear in `y`.



<table border = 1>
  <tr>
  <td valign="top">
  
  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
  <td valign="top">
  
  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">

  `right_join(x = superheroes, y = publishers)`
  
  

|name     |alignment |gender |publisher | yr_founded|
|:--------|:---------|:------|:---------|----------:|
|Batman   |good      |male   |DC        |       1934|
|Joker    |bad       |male   |DC        |       1934|
|Catwoman |bad       |female |DC        |       1934|
|Magneto  |bad       |male   |Marvel    |       1939|
|Storm    |good      |female |Marvel    |       1939|
|Mystique |bad       |female |Marvel    |       1939|
|NA       |NA        |NA     |Image     |       1992|


  
</td>
</tr>
</table>

## Full join

> `full_join(x, y)`: Return all rows and all columns from both `x` and `y`. Where there are not matching values, returns `NA` for the one missing. This is a mutating join.


```r
(fjsp <- full_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 8 x 5
##   name     alignment gender publisher     yr_founded
##   <chr>    <chr>     <chr>  <chr>              <dbl>
## 1 Magneto  bad       male   Marvel              1939
## 2 Storm    good      female Marvel              1939
## 3 Mystique bad       female Marvel              1939
## 4 Batman   good      male   DC                  1934
## 5 Joker    bad       male   DC                  1934
## 6 Catwoman bad       female DC                  1934
## 7 Sabrina  good      female Archie Comics         NA
## 8 <NA>     <NA>      <NA>   Image               1992
```

We get all rows of `x = superheroes` plus a new row from `y = publishers`, containing the publisher "Image". We get all variables from `x = superheroes` AND all variables from `y = publishers`. Any row that derives solely from one table or the other carries `NA`s in the variables found only in the other table.



<table border = 1>
<tr>
<td valign="top">

  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
<td valign="top">

  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">

  `full_join(x = superheroes, y = publishers)`
  
  

|name     |alignment |gender |publisher     | yr_founded|
|:--------|:---------|:------|:-------------|----------:|
|Magneto  |bad       |male   |Marvel        |       1939|
|Storm    |good      |female |Marvel        |       1939|
|Mystique |bad       |female |Marvel        |       1939|
|Batman   |good      |male   |DC            |       1934|
|Joker    |bad       |male   |DC            |       1934|
|Catwoman |bad       |female |DC            |       1934|
|Sabrina  |good      |female |Archie Comics |         NA|
|NA       |NA        |NA     |Image         |       1992|


  
</td>
</tr>
</table>

## Filtering joins

## Semi join

> `semi_join(x, y)`: Return all rows from `x` where there are matching values in `y`, keeping just columns from `x`. A semi join differs from an inner join because an inner join will return one row of `x` for each matching row of `y` (potentially duplicating rows in `x`), whereas a semi join will never duplicate rows of `x`. This is a filtering join.


```r
(sjsp <- semi_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 6 x 4
##   name     alignment gender publisher
##   <chr>    <chr>     <chr>  <chr>    
## 1 Magneto  bad       male   Marvel   
## 2 Storm    good      female Marvel   
## 3 Mystique bad       female Marvel   
## 4 Batman   good      male   DC       
## 5 Joker    bad       male   DC       
## 6 Catwoman bad       female DC
```

We get a similar result as with `inner_join()` but the join result contains only the variables originally found in `x = superheroes`. But note the row order has changed.



<table border = 1>
  <tr>
  <td valign="top">
  
  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
  <td valign="top">
  
  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">
  `semi_join(x = superheroes, y = publishers)`
  
  

|name     |alignment |gender |publisher |
|:--------|:---------|:------|:---------|
|Magneto  |bad       |male   |Marvel    |
|Storm    |good      |female |Marvel    |
|Mystique |bad       |female |Marvel    |
|Batman   |good      |male   |DC        |
|Joker    |bad       |male   |DC        |
|Catwoman |bad       |female |DC        |


  
</td>
</tr>
</table>

## Anti join

> `anti_join(x, y)`: Return all rows from `x` where there are not matching values in `y`, keeping just columns from `x`. This is a filtering join.


```r
(ajsp <- anti_join(x = superheroes, y = publishers))
```

```
## Joining, by = "publisher"
```

```
## # A tibble: 1 x 4
##   name    alignment gender publisher    
##   <chr>   <chr>     <chr>  <chr>        
## 1 Sabrina good      female Archie Comics
```

We keep **only** Sabrina now (and do not get `yr_founded`).



<table border = 1>
  <tr>
  <td valign="top">
  
  `superheroes`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> name </th>
   <th style="text-align:left;"> alignment </th>
   <th style="text-align:left;"> gender </th>
   <th style="text-align:left;"> publisher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Magneto </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Storm </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mystique </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Marvel </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Batman </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Joker </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> male </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Catwoman </td>
   <td style="text-align:left;"> bad </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> DC </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sabrina </td>
   <td style="text-align:left;"> good </td>
   <td style="text-align:left;"> female </td>
   <td style="text-align:left;"> Archie Comics </td>
  </tr>
</tbody>
</table>


  
</td>
  <td valign="top">
  
  `publishers`
  
  <table>
 <thead>
  <tr>
   <th style="text-align:left;"> publisher </th>
   <th style="text-align:right;"> yr_founded </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> DC </td>
   <td style="text-align:right;"> 1934 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marvel </td>
   <td style="text-align:right;"> 1939 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Image </td>
   <td style="text-align:right;"> 1992 </td>
  </tr>
</tbody>
</table>


  
</td>
</tr>
<tr>
<td valign="top" colspan="2">

  `anti_join(x = superheroes, y = publishers)`
  
  

|name    |alignment |gender |publisher     |
|:-------|:---------|:------|:-------------|
|Sabrina |good      |female |Archie Comics |


  
</td>
</tr>
</table>

### Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.6.0 (2019-04-26)
##  os       macOS Mojave 10.14.5        
##  system   x86_64, darwin15.6.0        
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2019-07-01                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package     * version date       lib source                     
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)             
##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)             
##  blogdown      0.12    2019-05-01 [1] CRAN (R 3.6.0)             
##  bookdown      0.11    2019-05-28 [1] CRAN (R 3.6.0)             
##  broom         0.5.2   2019-04-07 [1] CRAN (R 3.6.0)             
##  callr         3.2.0   2019-03-15 [1] CRAN (R 3.6.0)             
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 3.6.0)             
##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)             
##  codetools     0.2-16  2018-12-24 [1] CRAN (R 3.6.0)             
##  colorspace    1.4-1   2019-03-18 [1] CRAN (R 3.6.0)             
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)             
##  desc          1.2.0   2018-05-01 [1] CRAN (R 3.6.0)             
##  devtools      2.0.2   2019-04-08 [1] CRAN (R 3.6.0)             
##  digest        0.6.19  2019-05-20 [1] CRAN (R 3.6.0)             
##  dplyr       * 0.8.1   2019-05-14 [1] CRAN (R 3.6.0)             
##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)             
##  fansi         0.4.0   2018-10-05 [1] CRAN (R 3.6.0)             
##  forcats     * 0.4.0   2019-02-17 [1] CRAN (R 3.6.0)             
##  fs            1.3.1   2019-05-06 [1] CRAN (R 3.6.0)             
##  generics      0.0.2   2018-11-29 [1] CRAN (R 3.6.0)             
##  ggplot2     * 3.1.1   2019-04-07 [1] CRAN (R 3.6.0)             
##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)             
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 3.6.0)             
##  haven         2.1.0   2019-02-19 [1] CRAN (R 3.6.0)             
##  here          0.1     2017-05-28 [1] CRAN (R 3.6.0)             
##  highr         0.8     2019-03-20 [1] CRAN (R 3.6.0)             
##  hms           0.4.2   2018-03-10 [1] CRAN (R 3.6.0)             
##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)             
##  httr          1.4.0   2018-12-11 [1] CRAN (R 3.6.0)             
##  jsonlite      1.6     2018-12-07 [1] CRAN (R 3.6.0)             
##  knitr         1.23    2019-05-18 [1] CRAN (R 3.6.0)             
##  lattice       0.20-38 2018-11-04 [1] CRAN (R 3.6.0)             
##  lazyeval      0.2.2   2019-03-15 [1] CRAN (R 3.6.0)             
##  lubridate     1.7.4   2018-04-11 [1] CRAN (R 3.6.0)             
##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)             
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 3.6.0)             
##  modelr        0.1.4   2019-02-18 [1] CRAN (R 3.6.0)             
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 3.6.0)             
##  nlme          3.1-140 2019-05-12 [1] CRAN (R 3.6.0)             
##  pillar        1.4.1   2019-05-28 [1] CRAN (R 3.6.0)             
##  pkgbuild      1.0.3   2019-03-20 [1] CRAN (R 3.6.0)             
##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)             
##  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.6.0)             
##  plyr          1.8.4   2016-06-08 [1] CRAN (R 3.6.0)             
##  prettyunits   1.0.2   2015-07-13 [1] CRAN (R 3.6.0)             
##  processx      3.3.1   2019-05-08 [1] CRAN (R 3.6.0)             
##  ps            1.3.0   2018-12-21 [1] CRAN (R 3.6.0)             
##  purrr       * 0.3.2   2019-03-15 [1] CRAN (R 3.6.0)             
##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)             
##  rcfss       * 0.1.7   2019-07-02 [1] local                      
##  Rcpp          1.0.1   2019-03-17 [1] CRAN (R 3.6.0)             
##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)             
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 3.6.0)             
##  remotes       2.0.4   2019-04-10 [1] CRAN (R 3.6.0)             
##  rlang         0.3.4   2019-04-07 [1] CRAN (R 3.6.0)             
##  rmarkdown     1.13    2019-05-22 [1] CRAN (R 3.6.0)             
##  rprojroot     1.3-2   2018-01-03 [1] CRAN (R 3.6.0)             
##  rstudioapi    0.10    2019-03-19 [1] CRAN (R 3.6.0)             
##  rvest         0.3.4   2019-05-15 [1] CRAN (R 3.6.0)             
##  scales        1.0.0   2018-08-09 [1] CRAN (R 3.6.0)             
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)             
##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)             
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 3.6.0)             
##  testthat      2.1.1   2019-04-23 [1] CRAN (R 3.6.0)             
##  tibble      * 2.1.3   2019-06-06 [1] CRAN (R 3.6.0)             
##  tidyr       * 0.8.3   2019-03-01 [1] CRAN (R 3.6.0)             
##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)             
##  tidyverse   * 1.2.1   2017-11-14 [1] CRAN (R 3.6.0)             
##  usethis       1.5.0   2019-04-07 [1] CRAN (R 3.6.0)             
##  utf8          1.1.4   2018-05-24 [1] CRAN (R 3.6.0)             
##  vctrs         0.1.0   2018-11-29 [1] CRAN (R 3.6.0)             
##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)             
##  xfun          0.7.4   2019-06-10 [1] Github (yihui/xfun@cc966d3)
##  xml2          1.2.0   2018-01-24 [1] CRAN (R 3.6.0)             
##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)             
##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)             
## 
## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
```

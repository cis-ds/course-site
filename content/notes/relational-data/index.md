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

{{% callout note %}}

`inner_join(x, y)`: Return all rows from `x` where there are matching values in `y`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.

{{% /callout %}}


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

{{% callout note %}}

`left_join(x, y)`: Return all rows from `x`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.

{{% /callout %}}


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

{{% callout note %}}

`right_join(x, y)`: Return all rows from `y`, and all columns from `x` and `y`. If there are multiple matches between `x` and `y`, all combination of the matches are returned. This is a mutating join.

{{% /callout %}}


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
## 1 Magneto  bad       male   Marvel          1939
## 2 Storm    good      female Marvel          1939
## 3 Mystique bad       female Marvel          1939
## 4 Batman   good      male   DC              1934
## 5 Joker    bad       male   DC              1934
## 6 Catwoman bad       female DC              1934
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
|Magneto  |bad       |male   |Marvel    |       1939|
|Storm    |good      |female |Marvel    |       1939|
|Mystique |bad       |female |Marvel    |       1939|
|Batman   |good      |male   |DC        |       1934|
|Joker    |bad       |male   |DC        |       1934|
|Catwoman |bad       |female |DC        |       1934|
|NA       |NA        |NA     |Image     |       1992|


  
</td>
</tr>
</table>

## Full join

{{% callout note %}}

`full_join(x, y)`: Return all rows and all columns from both `x` and `y`. Where there are not matching values, returns `NA` for the one missing. This is a mutating join.

{{% /callout %}}


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

{{% callout note %}}

`semi_join(x, y)`: Return all rows from `x` where there are matching values in `y`, keeping just columns from `x`. A semi join differs from an inner join because an inner join will return one row of `x` for each matching row of `y` (potentially duplicating rows in `x`), whereas a semi join will never duplicate rows of `x`. This is a filtering join.

{{% /callout %}}


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

{{% callout note %}}

`anti_join(x, y)`: Return all rows from `x` where there are not matching values in `y`, keeping just columns from `x`. This is a filtering join.

{{% /callout %}}


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

## Acknowledgments


* This page is derived in part from ["UBC STAT 545A and 547M"](http://stat545.com), licensed under the [CC BY-NC 3.0 Creative Commons License](https://creativecommons.org/licenses/by-nc/3.0/).

## Session Info



```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 4.0.3 (2020-10-10)
##  os       macOS Catalina 10.15.7      
##  system   x86_64, darwin17.0          
##  ui       X11                         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       America/Chicago             
##  date     2021-01-21                  
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package     * version date       lib source        
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)
##  blogdown      1.1     2021-01-19 [1] CRAN (R 4.0.3)
##  bookdown      0.21    2020-10-13 [1] CRAN (R 4.0.2)
##  callr         3.5.1   2020-10-13 [1] CRAN (R 4.0.2)
##  cli           2.2.0   2020-11-20 [1] CRAN (R 4.0.2)
##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)
##  desc          1.2.0   2018-05-01 [1] CRAN (R 4.0.0)
##  devtools      2.3.2   2020-09-18 [1] CRAN (R 4.0.2)
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)
##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)
##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.2)
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
##  here          1.0.1   2020-12-13 [1] CRAN (R 4.0.2)
##  htmltools     0.5.1   2021-01-12 [1] CRAN (R 4.0.2)
##  knitr         1.30    2020-09-22 [1] CRAN (R 4.0.2)
##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)
##  memoise       1.1.0   2017-04-21 [1] CRAN (R 4.0.0)
##  pkgbuild      1.2.0   2020-12-15 [1] CRAN (R 4.0.2)
##  pkgload       1.1.0   2020-05-29 [1] CRAN (R 4.0.0)
##  prettyunits   1.1.1   2020-01-24 [1] CRAN (R 4.0.0)
##  processx      3.4.5   2020-11-30 [1] CRAN (R 4.0.2)
##  ps            1.5.0   2020-12-05 [1] CRAN (R 4.0.2)
##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.0)
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)
##  remotes       2.2.0   2020-07-21 [1] CRAN (R 4.0.2)
##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)
##  rmarkdown     2.6     2020-12-14 [1] CRAN (R 4.0.2)
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.2)
##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.0.0)
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)
##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.0)
##  testthat      3.0.1   2020-12-17 [1] CRAN (R 4.0.2)
##  usethis       2.0.0   2020-12-10 [1] CRAN (R 4.0.2)
##  withr         2.3.0   2020-09-22 [1] CRAN (R 4.0.2)
##  xfun          0.20    2021-01-06 [1] CRAN (R 4.0.2)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)
## 
## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
```

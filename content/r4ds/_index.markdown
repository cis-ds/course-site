---
date: "2018-09-09T00:00:00-05:00"
draft: false
title: "R for Data Science"
subtitle: "Exercise answer key"
type: post
aliases: "/r4da_solutions.html"
---



This is a work-in-progress answer key for the exercises in Hadley Wickham's [R for Data Science](http://r4ds.had.co.nz/). For many questions, there is more than one correct answer. This is simply what I came up with, attempting to limit myself to only using operations and functions the reader has seen in previous chapters.

> See an error or want to add an answer? [Submit a pull request.](https://github.com/uc-cfss/uc-cfss.github.io/pulls)

# Load prerequisites


```r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 3.1.0       ✔ purrr   0.3.2  
#> ✔ tibble  2.1.1       ✔ dplyr   0.8.0.1
#> ✔ tidyr   0.8.3       ✔ stringr 1.4.0  
#> ✔ readr   1.3.1       ✔ forcats 0.4.0
#> ── Conflicts ────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
```

# 3 Data visualization

## 3.2.4 Exercises

1.  Run `ggplot(data = mpg)` what do you see?

    
    ```r
    ggplot(data = mpg)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-1-1.png" width="70%" style="display: block; margin: auto;" />

1.  How many rows are in `mtcars`? How many columns?

    
    ```r
    # one approach
    nrow(mtcars)
    #> [1] 32
    ncol(mtcars)
    #> [1] 11
    
    # another approach
    dim(mtcars)
    #> [1] 32 11
    ```

1.  What does the `drv` variable describe? Read the help for `?mpg` to find
    out.
    
    `drv` indicates whether the vehicle is front-wheel drive, rear wheel drive, or 4 wheel drive.
    
1.  Make a scatterplot of `hwy` vs `cyl`.

    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = hwy, y = cyl))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-3-1.png" width="70%" style="display: block; margin: auto;" />
    
1.  What happens if you make a scatterplot of `class` vs `drv`. Why is
    the plot not useful?
    
    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = class, y = drv))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-4-1.png" width="70%" style="display: block; margin: auto;" />
    
    The variables are both categorical, so the points on the plot overlap with one another.

## 3.3.1 Exercises

1.  What's gone wrong with this code? Why are the points not blue?

    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-5-1.png" width="70%" style="display: block; margin: auto;" />
    
    Because the `color` argument was set within `aes()`, not `geom_point()`.
    
    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy), color = "blue")
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-6-1.png" width="70%" style="display: block; margin: auto;" />
    
1.  Which variables in `mpg` are categorical? Which variables are continuous? 
    (Hint: type `?mpg` to read the documentation for the dataset). How
    can you see this information when you run `mpg`?
    
    * Categorical - `manufacturer`, `model`, `trans`, `drv`, `fl`, `class`
    * Continuous - `displ`, `cyl`, `cty`, `hwy`
    * Categorical variables are type `chr`, whereas continuous variables are type `dbl` or `int`
    
    
    ```r
    mpg
    #> # A tibble: 234 x 11
    #>    manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
    #>    <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
    #>  1 audi         a4      1.8  1999     4 auto… f        18    29 p     comp…
    #>  2 audi         a4      1.8  1999     4 manu… f        21    29 p     comp…
    #>  3 audi         a4      2    2008     4 manu… f        20    31 p     comp…
    #>  4 audi         a4      2    2008     4 auto… f        21    30 p     comp…
    #>  5 audi         a4      2.8  1999     6 auto… f        16    26 p     comp…
    #>  6 audi         a4      2.8  1999     6 manu… f        18    26 p     comp…
    #>  7 audi         a4      3.1  2008     6 auto… f        18    27 p     comp…
    #>  8 audi         a4 q…   1.8  1999     4 manu… 4        18    26 p     comp…
    #>  9 audi         a4 q…   1.8  1999     4 auto… 4        16    25 p     comp…
    #> 10 audi         a4 q…   2    2008     4 manu… 4        20    28 p     comp…
    #> # … with 224 more rows
    ```

1.  Map a continuous variable to `color`, `size`, and `shape`. How do
    these aesthetics behave differently for categorical vs. continuous
    variables?
    
    
    ```r
    # color
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, color = cty))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-8-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # size
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, size = cty))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-8-2.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # shape
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, shape = cty))
    #> Error: A continuous variable can not be mapped to shape
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-8-3.png" width="70%" style="display: block; margin: auto;" />
    
    For these aesthetics, continuous variables are visualized on a spectrum (see the color plot with the continuous color palette), whereas categorical variables are binned into discrete categories, like this:
    
    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, color = class))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-9-1.png" width="70%" style="display: block; margin: auto;" />
    
1.  What happens if you map the same variable to multiple aesthetics? 

    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, color = cty, size = cty))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />
    
    Both aesthetics are implemented, and multiple legends are generated.

1.  What does the `stroke` aesthetic do? What shapes does it work with?
    (Hint: use `?geom_point`)
    
    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy), stroke = 3, shape = 21)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />
    
    `stroke` adjusts the thickness of the border for shapes that can take on different colors both inside and outside. [It only works for shapes 21-24.](http://docs.ggplot2.org/current/vignettes/ggplot2-specs.html)
    
    <img src="/r4ds/_index_files/figure-html/shapes-1.png" width="70%" style="display: block; margin: auto;" />
    
1.  What happens if you map an aesthetic to something other than a variable 
    name, like `aes(colour = displ < 5)`?
    
    
    ```r
    ggplot(data = mpg) +
      geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />
    
    R executes the code and creates a temporary variable containing the results of the operation. Here, the new variable takes on a value of `TRUE` if the engine displacement is less than 5 or `FALSE` if the engine displacement is more than or equal to 5.

## 3.5.1 Exercises

1.  What happens if you facet on a continuous variable?
    
    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = drv, y = cyl)) +
      facet_wrap(~ displ)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-13-1.png" width="70%" style="display: block; margin: auto;" />
    
    Your graph will not make much sense. R will try to draw a separate facet for each unique value of the continuous variable. If you have too many unique values, you may crash R.

1.  What do the empty cells in plot with `facet_grid(drv ~ cyl)` mean?
    How do they relate to this plot?
    
    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = drv, y = cyl))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = drv, y = cyl)) +
      facet_grid(drv ~ cyl)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" />
    
    Empty cells mean there are no observations in the data that have that unique combination of values. For instance, in this plot we can determine that there are no vehicles with 5 cylinders that are also 4 wheel drive vehicles. The plot is similar to the original one, just that each facet only appears to have a single data point.
    
1.  What plots does the following code make? What does `.` do?

    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy)) +
      facet_grid(drv ~ .)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-16-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy)) +
      facet_grid(. ~ cyl)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-16-2.png" width="70%" style="display: block; margin: auto;" />
    
    `.` acts a placeholder for no variable. In `facet_grid()`, this results in a plot faceted on a single dimension (1 by `\(N\)` or `\(N\)` by 1) rather than an `\(N\)` by `\(N\)` grid.

1.  Take the first faceted plot in this section:

    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy)) + 
      facet_wrap(~ class, nrow = 2)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-17-1.png" width="70%" style="display: block; margin: auto;" />
    
    What are the advantages to using faceting instead of the colour aesthetic?
    What are the disadvantages? How might the balance change if you had a 
    larger dataset?
    
    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy, color = class))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-18-1.png" width="70%" style="display: block; margin: auto;" />
    
    Faceting splits the data into separate grids and better visualizes trends within each individual facet. The disadvantage is that by doing so, it is harder to visualize the overall relationship across facets. The color aesthetic is fine when your dataset is small, but with larger datasets points may begin to overlap with one another. In this situation with a colored plot, jittering may not be sufficient because of the additional color aesthetic.
    
1.  Read `?facet_wrap`. What does `nrow` do? What does `ncol` do? What other
    options control the layout of the individual panels? Why doesn't
    `facet_grid()` have `nrow` and `ncol` variables?
    
    1. `nrow` sets how many rows the faceted plot will have.
    1. `ncol` sets how many columns the faceted plot will have.
    1. `as.table` determines the starting facet to begin filling the plot, and `dir` determines the starting direction for filling in the plot (horizontal or vertical).

1.  When using `facet_grid()` you should usually put the variable with more
    unique levels in the columns. Why?
    
    This will extend the plot vertically, where you typically have more viewing space. If you extend it horizontally, the plot will be compressed and harder to view.
    
    
    ```r
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy)) +
      facet_grid(trans ~ drv)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-19-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy)) +
      facet_grid(drv ~ trans)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-19-2.png" width="70%" style="display: block; margin: auto;" />

## 3.6.1 Exercises

1.  What geom would you use to draw a line chart? A boxplot? 
    A histogram? An area chart?
    
    * Line chart - `geom_line()`
    * Boxplot - `geom_boxplot()`
    * Histogram - `geom_histogram()`
    * Area chart - `geom_area()`

1.  Run this code in your head and predict what the output will look like.
    Then, run the code in R and check your predictions.
    
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
      geom_point() + 
      geom_smooth(se = FALSE)
    #> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />

1.  What does `show.legend = FALSE` do?  What happens if you remove it?  
    Why do you think I used it earlier in the chapter?
    
    It removes the legend. The aesthetics are still mapped and plotted, but the key is removed from the graph. I don't know why used it earlier because he actually did not.

1.  What does the `se` argument to `geom_smooth()` do?

    It determines whether or not to draw a confidence interval around the smoothing line.

1.  Will these two graphs look different? Why/why not?

    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_point() + 
      geom_smooth()
    #> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot() + 
      geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))
    #> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-21-2.png" width="70%" style="display: block; margin: auto;" />
    
    No because they use the same data and mapping settings. The only difference is that by storing it in the `ggplot()` function, it is automatically reused for each layer.

1.  Recreate the R code necessary to generate the following graphs.
    
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_point() + 
      geom_smooth(se = FALSE)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-1.png" width="70%" />
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_smooth(aes(group = drv), se = FALSE) +
      geom_point()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-2.png" width="70%" />
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
      geom_point() + 
      geom_smooth(se = FALSE)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-3.png" width="70%" />
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_point(aes(color = drv)) + 
      geom_smooth(se = FALSE)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-4.png" width="70%" />
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_point(aes(color = drv)) +
      geom_smooth(aes(linetype = drv), se = FALSE)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-5.png" width="70%" />
    
    ```r
    ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
      geom_point(size = 4, colour = "white") + 
      geom_point(aes(colour = drv))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-22-6.png" width="70%" />
    
## 3.8.1 Exercises

1.  What is the default geom associated with `stat_summary()`? How could
    you rewrite the previous plot to use that geom function instead of the 
    stat function?
    
    The default geom is `geom_pointrange()`. Rewritten, we could use:
    
    
    ```r
    ggplot(data = diamonds) +
      geom_pointrange(mapping = aes(x = cut, y = depth),
                      stat = "summary",
                      fun.ymin = min,
                      fun.ymax = max,
                      fun.y = median)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />

1.  What does `geom_col()` do? How is it different to `geom_bar()`?

    `geom_bar()` uses the `stat_count()` statistical transformation to draw the bar graph. `geom_col()` assumes the values have already been transformed to the appropriate values. `geom_bar(stat = "identity")` and `geom_col()` are equivalent.

1.  Most geoms and stats come in pairs that are almost always used in 
    concert. Read through the documentation and make a list of all the 
    pairs. What do they have in common?

1.  What variables does `stat_smooth()` compute? What parameters control
    its behaviour?
    
    `stat_smooth()` calculates four variables:
        
    1. `y` - predicted value
    1. `ymin` - lower pointwise confidence interval around the mean
    1. `ymax` - upper pointwise confidence interval around the mean
    1. `se` - standard error
    
    See `?stat_smooth` for more details on the specific parameters. Most importantly, `method` controls the smoothing method to be employed, `se` determines whether confidence interval should be plotted, and `level` determines the level of confidence interval to use.

1.  In our proportion bar chart, we need to set `group = 1`. Why? In other
    words what is the problem with these two graphs?
    
    
    ```r
    ggplot(data = diamonds) + 
      geom_bar(mapping = aes(x = cut, y = stat(prop)))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    ggplot(data = diamonds) + 
      geom_bar(mapping = aes(x = cut, fill = color, y = stat(prop)))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-24-2.png" width="70%" style="display: block; margin: auto;" />
    
    If we fail to set `group = 1`, the proportions for each cut are calculated using the complete dataset, rather than each subset of `cut`. Instead, we want the graphs to look like this:

    
    ```r
    ggplot(data = diamonds) + 
      geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    ggplot(data = diamonds) + 
      geom_bar(mapping = aes(x = cut, fill = color, y = stat(prop), group = 1))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-25-2.png" width="70%" style="display: block; margin: auto;" />

## 3.8.1 Exercises

1.  What is the problem with this plot? How could you improve it?

    
    ```r
    ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
      geom_point()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />
    
    Many of the data points overlap. We can jitter the points by adding some slight random noise, which will improve the overall visualization.

    
    ```r
    ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
      geom_jitter()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-27-1.png" width="70%" style="display: block; margin: auto;" />

1.  What parameters to `geom_jitter()` control the amount of jittering?

    `width` and `height`.

1.  Compare and contrast `geom_jitter()` with `geom_count()`.

    
    ```r
    ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
      geom_jitter()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-28-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
      geom_count()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-28-2.png" width="70%" style="display: block; margin: auto;" />
    
    Rather than adding random noise, `geom_count()` counts the number of observations at each location, then maps the count to point area. It makes larger points the more observations are located at that area, so the number of visible points is equal to `geom_point()`.

1.  What's the default position adjustment for `geom_boxplot()`? Create
    a visualisation of the `mpg` dataset that demonstrates it.
    
    The default position adjustment is `position_dodge()`.
    
    
    ```r
    ggplot(data = mpg, mapping = aes(x = class, y = hwy, color = drv)) + 
      geom_boxplot(position = "dodge")
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

## 3.9.1 Exercises

1.  Turn a stacked bar chart into a pie chart using `coord_polar()`.

    
    ```r
    ggplot(data = mpg, mapping = aes(x = factor(1), fill = class)) +
      geom_bar(width = 1) +
      coord_polar(theta = "y")
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-30-1.png" width="70%" style="display: block; margin: auto;" />

1.  What does `labs()` do? Read the documentation.

    `labs()` adds labels to the graph. You can add a title, subtitle, and a label for the `\(x\)` and `\(y\)` axes, as well as a caption.

1.  What's the difference between `coord_quickmap()` and `coord_map()`?

    `coord_map()` projects a portion of the earth (a three-dimensional object) onto a flat (two-dimensional) plane. `coord_map()` does not preserve straight lines and therefore is computationally intensive; `coord_quickmap()` preserves straight lines and is therefore faster to draw (though less accurate).

1.  What does the plot below tell you about the relationship between city
    and highway mpg? Why is `coord_fixed()` important? What does 
    `geom_abline()` do?
    
    
    ```r
    ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
      geom_point() + 
      geom_abline() +
      coord_fixed()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />
    
    The relationships is approximately linear, though overall cars have slightly better highway mileage than city mileage. But using `coord_fixed()`, the plot draws equal intervals on the `\(x\)` and `\(y\)` axes so they are directly comparable. `geom_abline()` draws a line that, by default, has an intercept of 0 and slope of 1. This aids us in our discovery that automobile gas efficiency is on average slightly higher for highways than city driving, though the slope of the relationship is still roughly 1-to-1.
    
# 4 Workflow: basics

## 4.4 Practice

1.  Why does this code not work?

    
    ```r
    my_variable <- 10
    my_varıable
    #> Error in eval(expr, envir, enclos): object 'my_varıable' not found
    ```
    
    The second line has a typo. It should be `my_variable`, not `my_varıable`.
    
1.  Tweak each of the following R commands so that they run correctly:

    
    ```r
    library(tidyverse)
    
    # incorrect
    ggplot(dota = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy))
    #> Error in FUN(X[[i]], ...): object 'displ' not found
    
    # correct
    ggplot(data = mpg) + 
      geom_point(mapping = aes(x = displ, y = hwy))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # incorrect
    fliter(mpg, cyl = 8)
    #> Error in fliter(mpg, cyl = 8): could not find function "fliter"
    filter(diamond, carat > 3)
    #> Error in filter(diamond, carat > 3): object 'diamond' not found
    
    # correct
    filter(mpg, cyl == 8)
    #> # A tibble: 70 x 11
    #>    manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
    #>    <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
    #>  1 audi         a6 q…   4.2  2008     8 auto… 4        16    23 p     mids…
    #>  2 chevrolet    c150…   5.3  2008     8 auto… r        14    20 r     suv  
    #>  3 chevrolet    c150…   5.3  2008     8 auto… r        11    15 e     suv  
    #>  4 chevrolet    c150…   5.3  2008     8 auto… r        14    20 r     suv  
    #>  5 chevrolet    c150…   5.7  1999     8 auto… r        13    17 r     suv  
    #>  6 chevrolet    c150…   6    2008     8 auto… r        12    17 r     suv  
    #>  7 chevrolet    corv…   5.7  1999     8 manu… r        16    26 p     2sea…
    #>  8 chevrolet    corv…   5.7  1999     8 auto… r        15    23 p     2sea…
    #>  9 chevrolet    corv…   6.2  2008     8 manu… r        16    26 p     2sea…
    #> 10 chevrolet    corv…   6.2  2008     8 auto… r        15    25 p     2sea…
    #> # … with 60 more rows
    filter(diamonds, carat > 3)
    #> # A tibble: 32 x 10
    #>    carat cut     color clarity depth table price     x     y     z
    #>    <dbl> <ord>   <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
    #>  1  3.01 Premium I     I1       62.7    58  8040  9.1   8.97  5.67
    #>  2  3.11 Fair    J     I1       65.9    57  9823  9.15  9.02  5.98
    #>  3  3.01 Premium F     I1       62.2    56  9925  9.24  9.13  5.73
    #>  4  3.05 Premium E     I1       60.9    58 10453  9.26  9.25  5.66
    #>  5  3.02 Fair    I     I1       65.2    56 10577  9.11  9.02  5.91
    #>  6  3.01 Fair    H     I1       56.1    62 10761  9.54  9.38  5.31
    #>  7  3.65 Fair    H     I1       67.1    53 11668  9.53  9.48  6.38
    #>  8  3.24 Premium H     I1       62.1    58 12300  9.44  9.4   5.85
    #>  9  3.22 Ideal   I     I1       62.6    55 12545  9.49  9.42  5.92
    #> 10  3.5  Ideal   H     I1       62.8    57 12587  9.65  9.59  6.03
    #> # … with 22 more rows
    ```
    
1.  Press Alt + Shift + K. What happens? How can you get to the same place
    using the menus?
    
    The keyboard shortcuts help display appears. To access it from the menus, go to *Help* > *Keyboard Shortcuts Help*


# 5 Data transformation

## 5.7.1 Exercises

1.  Find all flights that

    1. Had an arrival delay of two or more hours
    
        
        ```r
        library(nycflights13)
        filter(flights, arr_delay >= 120)
        #> # A tibble: 10,200 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1     1      811            630       101     1047
        #>  2  2013     1     1      848           1835       853     1001
        #>  3  2013     1     1      957            733       144     1056
        #>  4  2013     1     1     1114            900       134     1447
        #>  5  2013     1     1     1505           1310       115     1638
        #>  6  2013     1     1     1525           1340       105     1831
        #>  7  2013     1     1     1549           1445        64     1912
        #>  8  2013     1     1     1558           1359       119     1718
        #>  9  2013     1     1     1732           1630        62     2028
        #> 10  2013     1     1     1803           1620       103     2008
        #> # … with 10,190 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Flew to Houston (`IAH` or `HOU`)
    
        
        ```r
        filter(flights, dest == "IAH" | dest == "HOU")
        #> # A tibble: 9,313 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1     1      517            515         2      830
        #>  2  2013     1     1      533            529         4      850
        #>  3  2013     1     1      623            627        -4      933
        #>  4  2013     1     1      728            732        -4     1041
        #>  5  2013     1     1      739            739         0     1104
        #>  6  2013     1     1      908            908         0     1228
        #>  7  2013     1     1     1028           1026         2     1350
        #>  8  2013     1     1     1044           1045        -1     1352
        #>  9  2013     1     1     1114            900       134     1447
        #> 10  2013     1     1     1205           1200         5     1503
        #> # … with 9,303 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Were operated by United, American, or Delta
    
        
        ```r
        filter(flights, carrier == "UA" |
                 carrier == "AA" |
                 carrier == "DL")
        #> # A tibble: 139,504 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1     1      517            515         2      830
        #>  2  2013     1     1      533            529         4      850
        #>  3  2013     1     1      542            540         2      923
        #>  4  2013     1     1      554            600        -6      812
        #>  5  2013     1     1      554            558        -4      740
        #>  6  2013     1     1      558            600        -2      753
        #>  7  2013     1     1      558            600        -2      924
        #>  8  2013     1     1      558            600        -2      923
        #>  9  2013     1     1      559            600        -1      941
        #> 10  2013     1     1      559            600        -1      854
        #> # … with 139,494 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Departed in summer (July, August, and September)
    
        
        ```r
        filter(flights, month >= 7, month <= 9)
        #> # A tibble: 86,326 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     7     1        1           2029       212      236
        #>  2  2013     7     1        2           2359         3      344
        #>  3  2013     7     1       29           2245       104      151
        #>  4  2013     7     1       43           2130       193      322
        #>  5  2013     7     1       44           2150       174      300
        #>  6  2013     7     1       46           2051       235      304
        #>  7  2013     7     1       48           2001       287      308
        #>  8  2013     7     1       58           2155       183      335
        #>  9  2013     7     1      100           2146       194      327
        #> 10  2013     7     1      100           2245       135      337
        #> # … with 86,316 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Arrived more than two hours late, but didn't leave late
    
        
        ```r
        filter(flights, arr_delay >= 120, dep_delay <= 0)
        #> # A tibble: 29 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1    27     1419           1420        -1     1754
        #>  2  2013    10     7     1350           1350         0     1736
        #>  3  2013    10     7     1357           1359        -2     1858
        #>  4  2013    10    16      657            700        -3     1258
        #>  5  2013    11     1      658            700        -2     1329
        #>  6  2013     3    18     1844           1847        -3       39
        #>  7  2013     4    17     1635           1640        -5     2049
        #>  8  2013     4    18      558            600        -2     1149
        #>  9  2013     4    18      655            700        -5     1213
        #> 10  2013     5    22     1827           1830        -3     2217
        #> # … with 19 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Were delayed by at least an hour, but made up over 30 minutes in flight
    
        
        ```r
        filter(flights, dep_delay >= 60, dep_delay - arr_delay >= 30)
        #> # A tibble: 2,074 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1     1     1716           1545        91     2140
        #>  2  2013     1     1     2205           1720       285       46
        #>  3  2013     1     1     2326           2130       116      131
        #>  4  2013     1     3     1503           1221       162     1803
        #>  5  2013     1     3     1821           1530       171     2131
        #>  6  2013     1     3     1839           1700        99     2056
        #>  7  2013     1     3     1850           1745        65     2148
        #>  8  2013     1     3     1923           1815        68     2036
        #>  9  2013     1     3     1941           1759       102     2246
        #> 10  2013     1     3     1950           1845        65     2228
        #> # … with 2,064 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```
    
    1. Departed between midnight and 6am (inclusive)
    
        
        ```r
        filter(flights, dep_time >=0, dep_time <= 600)
        #> # A tibble: 9,344 x 19
        #>     year month   day dep_time sched_dep_time dep_delay arr_time
        #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
        #>  1  2013     1     1      517            515         2      830
        #>  2  2013     1     1      533            529         4      850
        #>  3  2013     1     1      542            540         2      923
        #>  4  2013     1     1      544            545        -1     1004
        #>  5  2013     1     1      554            600        -6      812
        #>  6  2013     1     1      554            558        -4      740
        #>  7  2013     1     1      555            600        -5      913
        #>  8  2013     1     1      557            600        -3      709
        #>  9  2013     1     1      557            600        -3      838
        #> 10  2013     1     1      558            600        -2      753
        #> # … with 9,334 more rows, and 12 more variables: sched_arr_time <int>,
        #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
        #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
        #> #   minute <dbl>, time_hour <dttm>
        ```

1.  Another useful dplyr filtering helper is `between()`. What does it do?
    Can you use it to simplify the code needed to answer the previous 
    challenges?
    
    It is a shortcut for finding observations between two values. For example, we can simplify this code:
    
    
    ```r
    filter(flights, month >= 7, month <= 9)
    #> # A tibble: 86,326 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     7     1        1           2029       212      236
    #>  2  2013     7     1        2           2359         3      344
    #>  3  2013     7     1       29           2245       104      151
    #>  4  2013     7     1       43           2130       193      322
    #>  5  2013     7     1       44           2150       174      300
    #>  6  2013     7     1       46           2051       235      304
    #>  7  2013     7     1       48           2001       287      308
    #>  8  2013     7     1       58           2155       183      335
    #>  9  2013     7     1      100           2146       194      327
    #> 10  2013     7     1      100           2245       135      337
    #> # … with 86,316 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    filter(flights, between(month, 7, 9))
    #> # A tibble: 86,326 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     7     1        1           2029       212      236
    #>  2  2013     7     1        2           2359         3      344
    #>  3  2013     7     1       29           2245       104      151
    #>  4  2013     7     1       43           2130       193      322
    #>  5  2013     7     1       44           2150       174      300
    #>  6  2013     7     1       46           2051       235      304
    #>  7  2013     7     1       48           2001       287      308
    #>  8  2013     7     1       58           2155       183      335
    #>  9  2013     7     1      100           2146       194      327
    #> 10  2013     7     1      100           2245       135      337
    #> # … with 86,316 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```

1.  How many flights have a missing `dep_time`? What other variables are 
    missing? What might these rows represent?
    
    
    ```r
    filter(flights, is.na(dep_time))
    #> # A tibble: 8,255 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     1       NA           1630        NA       NA
    #>  2  2013     1     1       NA           1935        NA       NA
    #>  3  2013     1     1       NA           1500        NA       NA
    #>  4  2013     1     1       NA            600        NA       NA
    #>  5  2013     1     2       NA           1540        NA       NA
    #>  6  2013     1     2       NA           1620        NA       NA
    #>  7  2013     1     2       NA           1355        NA       NA
    #>  8  2013     1     2       NA           1420        NA       NA
    #>  9  2013     1     2       NA           1321        NA       NA
    #> 10  2013     1     2       NA           1545        NA       NA
    #> # … with 8,245 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```
    
    They are also missing values for arrival time and departure/arrival delay. Most likely these are scheduled flights that never flew.

1.  Why is `NA ^ 0` not missing? Why is `NA | TRUE` not missing?
    Why is `FALSE & NA` not missing? Can you figure out the general
    rule?  (`NA * 0` is a tricky counterexample!)
    
    * `NA ^ 0` - by definition anything to the 0th power is 1.
    * `NA | TRUE` - as long as one condition is `TRUE`, the result is `TRUE`. By definition, `TRUE` is `TRUE`.
    * `FALSE & NA` - `NA` indicates the absence of a value, so the conditional expression ignores it.
    * In general any operation on a missing value becomes a missing value. Hence `NA * 0` is `NA`. In conditional expressions, missing values are simply ignored.

## 5.3.1 Exercises

1.  How could you use `arrange()` to sort all missing values to the start?
    (Hint: use `is.na()`).
    
    
    ```r
    arrange(data, !is.na(.))
    ```
    
    A working example:
    
    
    ```r
    arrange(flights, !is.na(dep_time))
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     1       NA           1630        NA       NA
    #>  2  2013     1     1       NA           1935        NA       NA
    #>  3  2013     1     1       NA           1500        NA       NA
    #>  4  2013     1     1       NA            600        NA       NA
    #>  5  2013     1     2       NA           1540        NA       NA
    #>  6  2013     1     2       NA           1620        NA       NA
    #>  7  2013     1     2       NA           1355        NA       NA
    #>  8  2013     1     2       NA           1420        NA       NA
    #>  9  2013     1     2       NA           1321        NA       NA
    #> 10  2013     1     2       NA           1545        NA       NA
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```
    
1.  Sort `flights` to find the most delayed flights. Find the flights that
    left earliest.
    
    
    ```r
    # most delayed (based on arrival)
    arrange(flights, desc(arr_delay))
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     9      641            900      1301     1242
    #>  2  2013     6    15     1432           1935      1137     1607
    #>  3  2013     1    10     1121           1635      1126     1239
    #>  4  2013     9    20     1139           1845      1014     1457
    #>  5  2013     7    22      845           1600      1005     1044
    #>  6  2013     4    10     1100           1900       960     1342
    #>  7  2013     3    17     2321            810       911      135
    #>  8  2013     7    22     2257            759       898      121
    #>  9  2013    12     5      756           1700       896     1058
    #> 10  2013     5     3     1133           2055       878     1250
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    
    # left earliest
    arrange(flights, dep_delay)
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013    12     7     2040           2123       -43       40
    #>  2  2013     2     3     2022           2055       -33     2240
    #>  3  2013    11    10     1408           1440       -32     1549
    #>  4  2013     1    11     1900           1930       -30     2233
    #>  5  2013     1    29     1703           1730       -27     1947
    #>  6  2013     8     9      729            755       -26     1002
    #>  7  2013    10    23     1907           1932       -25     2143
    #>  8  2013     3    30     2030           2055       -25     2213
    #>  9  2013     3     2     1431           1455       -24     1601
    #> 10  2013     5     5      934            958       -24     1225
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```

1.  Sort `flights` to find the fastest flights.

    
    ```r
    arrange(flights, desc(distance / air_time))
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     5    25     1709           1700         9     1923
    #>  2  2013     7     2     1558           1513        45     1745
    #>  3  2013     5    13     2040           2025        15     2225
    #>  4  2013     3    23     1914           1910         4     2045
    #>  5  2013     1    12     1559           1600        -1     1849
    #>  6  2013    11    17      650            655        -5     1059
    #>  7  2013     2    21     2355           2358        -3      412
    #>  8  2013    11    17      759            800        -1     1212
    #>  9  2013    11    16     2003           1925        38       17
    #> 10  2013    11    16     2349           2359       -10      402
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```

1.  Which flights travelled the longest? Which travelled the shortest?

    
    ```r
    # longest flights by distance
    arrange(flights, desc(distance))
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     1      857            900        -3     1516
    #>  2  2013     1     2      909            900         9     1525
    #>  3  2013     1     3      914            900        14     1504
    #>  4  2013     1     4      900            900         0     1516
    #>  5  2013     1     5      858            900        -2     1519
    #>  6  2013     1     6     1019            900        79     1558
    #>  7  2013     1     7     1042            900       102     1620
    #>  8  2013     1     8      901            900         1     1504
    #>  9  2013     1     9      641            900      1301     1242
    #> 10  2013     1    10      859            900        -1     1449
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    
    # shortest flights by distance
    arrange(flights, distance)
    #> # A tibble: 336,776 x 19
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     7    27       NA            106        NA       NA
    #>  2  2013     1     3     2127           2129        -2     2222
    #>  3  2013     1     4     1240           1200        40     1333
    #>  4  2013     1     4     1829           1615       134     1937
    #>  5  2013     1     4     2128           2129        -1     2218
    #>  6  2013     1     5     1155           1200        -5     1241
    #>  7  2013     1     6     2125           2129        -4     2224
    #>  8  2013     1     7     2124           2129        -5     2212
    #>  9  2013     1     8     2127           2130        -3     2304
    #> 10  2013     1     9     2126           2129        -3     2217
    #> # … with 336,766 more rows, and 12 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>
    ```

## 5.4.1 Exercises

1.  Brainstorm as many ways as possible to select `dep_time`, `dep_delay`,
    `arr_time`, and `arr_delay` from `flights`.
    
    
    ```r
    select(flights, dep_time, dep_delay, arr_time, arr_delay)
    #> # A tibble: 336,776 x 4
    #>    dep_time dep_delay arr_time arr_delay
    #>       <int>     <dbl>    <int>     <dbl>
    #>  1      517         2      830        11
    #>  2      533         4      850        20
    #>  3      542         2      923        33
    #>  4      544        -1     1004       -18
    #>  5      554        -6      812       -25
    #>  6      554        -4      740        12
    #>  7      555        -5      913        19
    #>  8      557        -3      709       -14
    #>  9      557        -3      838        -8
    #> 10      558        -2      753         8
    #> # … with 336,766 more rows
    select(flights, starts_with("dep"), starts_with("arr"))
    #> # A tibble: 336,776 x 4
    #>    dep_time dep_delay arr_time arr_delay
    #>       <int>     <dbl>    <int>     <dbl>
    #>  1      517         2      830        11
    #>  2      533         4      850        20
    #>  3      542         2      923        33
    #>  4      544        -1     1004       -18
    #>  5      554        -6      812       -25
    #>  6      554        -4      740        12
    #>  7      555        -5      913        19
    #>  8      557        -3      709       -14
    #>  9      557        -3      838        -8
    #> 10      558        -2      753         8
    #> # … with 336,766 more rows
    select(flights, ends_with("delay"))
    #> # A tibble: 336,776 x 2
    #>    dep_delay arr_delay
    #>        <dbl>     <dbl>
    #>  1         2        11
    #>  2         4        20
    #>  3         2        33
    #>  4        -1       -18
    #>  5        -6       -25
    #>  6        -4        12
    #>  7        -5        19
    #>  8        -3       -14
    #>  9        -3        -8
    #> 10        -2         8
    #> # … with 336,766 more rows
    select(flights, contains("delay"))
    #> # A tibble: 336,776 x 2
    #>    dep_delay arr_delay
    #>        <dbl>     <dbl>
    #>  1         2        11
    #>  2         4        20
    #>  3         2        33
    #>  4        -1       -18
    #>  5        -6       -25
    #>  6        -4        12
    #>  7        -5        19
    #>  8        -3       -14
    #>  9        -3        -8
    #> 10        -2         8
    #> # … with 336,766 more rows
    ```
    
1.  What happens if you include the name of a variable multiple times in
    a `select()` call?
    
    It is included only a single time in the new data frame.
  
1.  What does the `one_of()` function do? Why might it be helpful in conjunction
    with this vector?
    
    
    ```r
    vars <- c("year", "month", "day", "dep_delay", "arr_delay")
    ```
    
    It selects any variable which matches one of the strings in the vector.
    
    
    ```r
    select(flights, one_of(vars))
    #> # A tibble: 336,776 x 5
    #>     year month   day dep_delay arr_delay
    #>    <int> <int> <int>     <dbl>     <dbl>
    #>  1  2013     1     1         2        11
    #>  2  2013     1     1         4        20
    #>  3  2013     1     1         2        33
    #>  4  2013     1     1        -1       -18
    #>  5  2013     1     1        -6       -25
    #>  6  2013     1     1        -4        12
    #>  7  2013     1     1        -5        19
    #>  8  2013     1     1        -3       -14
    #>  9  2013     1     1        -3        -8
    #> 10  2013     1     1        -2         8
    #> # … with 336,766 more rows
    ```
    
1.  Does the result of running the following code surprise you?  How do the
    select helpers deal with case by default? How can you change that default?

    
    ```r
    select(flights, contains("TIME"))
    #> # A tibble: 336,776 x 6
    #>    dep_time sched_dep_time arr_time sched_arr_time air_time
    #>       <int>          <int>    <int>          <int>    <dbl>
    #>  1      517            515      830            819      227
    #>  2      533            529      850            830      227
    #>  3      542            540      923            850      160
    #>  4      544            545     1004           1022      183
    #>  5      554            600      812            837      116
    #>  6      554            558      740            728      150
    #>  7      555            600      913            854      158
    #>  8      557            600      709            723       53
    #>  9      557            600      838            846      140
    #> 10      558            600      753            745      138
    #> # … with 336,766 more rows, and 1 more variable: time_hour <dttm>
    ```
    
    By default the select helpers ignore case. To adhere to case, set `ignore.case = FALSE` in the helper function. For example:
    
    
    ```r
    select(flights, contains("TIME", ignore.case = FALSE))
    #> # A tibble: 336,776 x 0
    ```

## 5.5.2 Exercises

1.  Currently `dep_time` and `sched_dep_time` are convenient to look at, but
    hard to compute with because they're not really continuous numbers. 
    Convert them to a more convenient representation of number of minutes
    since midnight.
    
    
    ```r
    transmute(flights,
           sched_dep_time = (sched_dep_time %/% 100) * 60 + sched_dep_time %% 100,
           dep_time = (dep_time %/% 100) * 60 + dep_time %% 100)
    #> # A tibble: 336,776 x 2
    #>    sched_dep_time dep_time
    #>             <dbl>    <dbl>
    #>  1            315      317
    #>  2            329      333
    #>  3            340      342
    #>  4            345      344
    #>  5            360      354
    #>  6            358      354
    #>  7            360      355
    #>  8            360      357
    #>  9            360      357
    #> 10            360      358
    #> # … with 336,766 more rows
    ```
    
1.  Compare `air_time` with `arr_time - dep_time`. What do you expect to see?
    What do you see? What do you need to do to fix it?
    
    
    ```r
    flights2 <- select(flights, air_time, arr_time, dep_time)
    mutate(flights2, air_time_new = arr_time - dep_time)
    #> # A tibble: 336,776 x 4
    #>    air_time arr_time dep_time air_time_new
    #>       <dbl>    <int>    <int>        <int>
    #>  1      227      830      517          313
    #>  2      227      850      533          317
    #>  3      160      923      542          381
    #>  4      183     1004      544          460
    #>  5      116      812      554          258
    #>  6      150      740      554          186
    #>  7      158      913      555          358
    #>  8       53      709      557          152
    #>  9      140      838      557          281
    #> 10      138      753      558          195
    #> # … with 336,766 more rows
    ```
    
    They are not the same because `dep_time` and `arr_time` are not measured in minutes, but are numerical representations of the time. We need to convert them to continuous numbers like above to make the correct calculation for `air_time`.
    
1.  Compare `dep_time`, `sched_dep_time`, and `dep_delay`. How would you
    expect those three numbers to be related?
    
    `dep_time` should equal `sched_dep_time` `\(+\)` `dep_delay` (after accounting for the fact that they are not stored continuously).

1.  Find the 10 most delayed flights using a ranking function. How do you want 
    to handle ties? Carefully read the documentation for `min_rank()`.
    
    
    ```r
    delayed <- mutate(flights, most_delayed = min_rank(desc(arr_delay)))
    arrange(delayed, most_delayed)
    #> # A tibble: 336,776 x 20
    #>     year month   day dep_time sched_dep_time dep_delay arr_time
    #>    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    #>  1  2013     1     9      641            900      1301     1242
    #>  2  2013     6    15     1432           1935      1137     1607
    #>  3  2013     1    10     1121           1635      1126     1239
    #>  4  2013     9    20     1139           1845      1014     1457
    #>  5  2013     7    22      845           1600      1005     1044
    #>  6  2013     4    10     1100           1900       960     1342
    #>  7  2013     3    17     2321            810       911      135
    #>  8  2013     7    22     2257            759       898      121
    #>  9  2013    12     5      756           1700       896     1058
    #> 10  2013     5     3     1133           2055       878     1250
    #> # … with 336,766 more rows, and 13 more variables: sched_arr_time <int>,
    #> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
    #> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
    #> #   minute <dbl>, time_hour <dttm>, most_delayed <int>
    ```
    
    I used `min_rank()` which assigns ties to the lowest rank. See [here](http://stats.stackexchange.com/questions/34008/how-does-ties-method-argument-of-rs-rank-function-work) for a detailed discussion of potential tie breaking methods.

1.  What does `1:3 + 1:10` return? Why?

    
    ```r
    1:3 + 1:10
    #> Warning in 1:3 + 1:10: longer object length is not a multiple of shorter
    #> object length
    #>  [1]  2  4  6  5  7  9  8 10 12 11
    ```
    
    Because the two vectors are not the same length, R **recycles** the shorter one until each vector is the same length. Then R adds the first elements together, then the second elements, then the third, etc.

1.  What trigonometric functions does R provide?

    [Cosine, sine, tangent, arc-tangent, arc-sine, arc-tangent, and the two-argument arc-tangent.](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Trig.html)

## 5.6.7 Exercises

1.  Brainstorm at least 5 different ways to assess the typical delay 
    characteristics of a group of flights. Consider the following scenarios:
    
    * A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of 
      the time.
      
    * A flight is always 10 minutes late.

    * A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of 
      the time.
      
    * 99% of the time a flight is on time. 1% of the time it's 2 hours late.
    
    Which is more important: arrival delay or departure delay?
    
    
    ```r
    # A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
    flights %>%
      group_by(flight) %>%
      summarize(early_15_min = sum(arr_delay <= -15, na.rm = TRUE) / n(),
                late_15_min = sum(arr_delay >= 15, na.rm = TRUE) / n()) %>%
      filter(early_15_min == 0.5,
             late_15_min == 0.5)
    #> # A tibble: 18 x 3
    #>    flight early_15_min late_15_min
    #>     <int>        <dbl>       <dbl>
    #>  1    107          0.5         0.5
    #>  2   2072          0.5         0.5
    #>  3   2366          0.5         0.5
    #>  4   2500          0.5         0.5
    #>  5   2552          0.5         0.5
    #>  6   3495          0.5         0.5
    #>  7   3518          0.5         0.5
    #>  8   3544          0.5         0.5
    #>  9   3651          0.5         0.5
    #> 10   3705          0.5         0.5
    #> 11   3916          0.5         0.5
    #> 12   3951          0.5         0.5
    #> 13   4273          0.5         0.5
    #> 14   4313          0.5         0.5
    #> 15   5297          0.5         0.5
    #> 16   5322          0.5         0.5
    #> 17   5388          0.5         0.5
    #> 18   5505          0.5         0.5
    
    # A flight is always 10 minutes late.
    flights %>%
      group_by(flight) %>%
      summarize(late_10 = sum(arr_delay == 10, na.rm = TRUE) / n()) %>%
      filter(late_10 == 1)
    #> # A tibble: 4 x 2
    #>   flight late_10
    #>    <int>   <dbl>
    #> 1   2254       1
    #> 2   3656       1
    #> 3   3880       1
    #> 4   5854       1
    
    # A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.
    flights %>%
      group_by(flight) %>%
      summarize(early_30_min = sum(arr_delay <= -30, na.rm = TRUE) / n(),
                late_30_min = sum(arr_delay >= 30, na.rm = TRUE) / n()) %>%
      filter(early_30_min == 0.5,
             late_30_min == 0.5)
    #> # A tibble: 3 x 3
    #>   flight early_30_min late_30_min
    #>    <int>        <dbl>       <dbl>
    #> 1   3651          0.5         0.5
    #> 2   3916          0.5         0.5
    #> 3   3951          0.5         0.5
    
    # 99% of the time a flight is on time. 1% of the time it's 2 hours late.
    flights %>%
      group_by(flight) %>%
      summarize(on_time = sum(arr_delay == 0, na.rm = TRUE) / n(),
                late_2_hours = sum(arr_delay >= 120, na.rm = TRUE) / n()) %>%
      filter(on_time == .99,
             late_2_hours == .01)
    #> # A tibble: 0 x 3
    #> # … with 3 variables: flight <int>, on_time <dbl>, late_2_hours <dbl>
    ```
    
    Delay type importance depends on individual preference. If an individual hates waiting in the terminal for the flight to take off, then departure delay is more important. If the individual cares more about arriving at their destination on time (which I personally care more about), then arrival delay is most important.

1.  Come up with another approach that will give you the same output as 
    `not_cancelled %>% count(dest)` and 
    `not_cancelled %>% count(tailnum, wt = distance)` (without using 
    `count()`).
    
    
    ```r
    not_cancelled <- flights %>% 
      filter(!is.na(dep_delay), !is.na(arr_delay))
    
    # original
    not_cancelled %>%
      count(dest)
    #> # A tibble: 104 x 2
    #>    dest      n
    #>    <chr> <int>
    #>  1 ABQ     254
    #>  2 ACK     264
    #>  3 ALB     418
    #>  4 ANC       8
    #>  5 ATL   16837
    #>  6 AUS    2411
    #>  7 AVL     261
    #>  8 BDL     412
    #>  9 BGR     358
    #> 10 BHM     269
    #> # … with 94 more rows
    
    # new
    not_cancelled %>%
      group_by(dest) %>%
      summarize(n = n())
    #> # A tibble: 104 x 2
    #>    dest      n
    #>    <chr> <int>
    #>  1 ABQ     254
    #>  2 ACK     264
    #>  3 ALB     418
    #>  4 ANC       8
    #>  5 ATL   16837
    #>  6 AUS    2411
    #>  7 AVL     261
    #>  8 BDL     412
    #>  9 BGR     358
    #> 10 BHM     269
    #> # … with 94 more rows
    
    # original
    not_cancelled %>%
      count(tailnum, wt = distance)
    #> # A tibble: 4,037 x 2
    #>    tailnum      n
    #>    <chr>    <dbl>
    #>  1 D942DN    3418
    #>  2 N0EGMQ  239143
    #>  3 N10156  109664
    #>  4 N102UW   25722
    #>  5 N103US   24619
    #>  6 N104UW   24616
    #>  7 N10575  139903
    #>  8 N105UW   23618
    #>  9 N107US   21677
    #> 10 N108UW   32070
    #> # … with 4,027 more rows
    
    # new
    not_cancelled %>%
      group_by(tailnum) %>%
      summarize(n = sum(distance, na.rm = TRUE))
    #> # A tibble: 4,037 x 2
    #>    tailnum      n
    #>    <chr>    <dbl>
    #>  1 D942DN    3418
    #>  2 N0EGMQ  239143
    #>  3 N10156  109664
    #>  4 N102UW   25722
    #>  5 N103US   24619
    #>  6 N104UW   24616
    #>  7 N10575  139903
    #>  8 N105UW   23618
    #>  9 N107US   21677
    #> 10 N108UW   32070
    #> # … with 4,027 more rows
    ```

1.  Our definition of cancelled flights (`is.na(dep_delay) | is.na(arr_delay)`
    ) is slightly suboptimal. Why? Which is the most important column?
    
    There are no flights which arrived but did not depart, so we can just use `!is.na(dep_delay)`.

1.  Look at the number of cancelled flights per day. Is there a pattern?
    Is the proportion of cancelled flights related to the average delay?
    
    **NOTE: I assume when the question refers to "per day", I am only grouping by `day`. Alternatively this could mean to group by calendar day, which would require grouping by `year`, `month`, and `day`.
    
    
    ```r
    flights %>%
      filter(is.na(dep_delay)) %>%
      count(day)
    #> # A tibble: 31 x 2
    #>      day     n
    #>    <int> <int>
    #>  1     1   246
    #>  2     2   250
    #>  3     3   109
    #>  4     4    82
    #>  5     5   226
    #>  6     6   296
    #>  7     7   318
    #>  8     8   921
    #>  9     9   593
    #> 10    10   535
    #> # … with 21 more rows
    
    flights %>%
      group_by(day) %>%
      summarize(prop_canceled = sum(is.na(dep_delay)) / n(),
                avg_delay = mean(dep_delay, na.rm = TRUE))
    #> # A tibble: 31 x 3
    #>      day prop_canceled avg_delay
    #>    <int>         <dbl>     <dbl>
    #>  1     1       0.0223      14.2 
    #>  2     2       0.0231      14.1 
    #>  3     3       0.00972     10.8 
    #>  4     4       0.00741      5.79
    #>  5     5       0.0208       7.82
    #>  6     6       0.0268       6.99
    #>  7     7       0.0289      14.3 
    #>  8     8       0.0817      21.8 
    #>  9     9       0.0546      14.6 
    #> 10    10       0.0477      18.3 
    #> # … with 21 more rows
    ```

1.  Which carrier has the worst delays? Challenge: can you disentangle the
    effects of bad airports vs. bad carriers? Why/why not? (Hint: think about
    `flights %>% group_by(carrier, dest) %>% summarise(n())`)
    
    
    ```r
    # worst delays
    flights %>%
      group_by(carrier) %>%
      summarize(mean_delay = mean(arr_delay, na.rm = TRUE)) %>%
      arrange(desc(mean_delay))
    #> # A tibble: 16 x 2
    #>    carrier mean_delay
    #>    <chr>        <dbl>
    #>  1 F9          21.9  
    #>  2 FL          20.1  
    #>  3 EV          15.8  
    #>  4 YV          15.6  
    #>  5 OO          11.9  
    #>  6 MQ          10.8  
    #>  7 WN           9.65 
    #>  8 B6           9.46 
    #>  9 9E           7.38 
    #> 10 UA           3.56 
    #> 11 US           2.13 
    #> 12 VX           1.76 
    #> 13 DL           1.64 
    #> 14 AA           0.364
    #> 15 HA          -6.92 
    #> 16 AS          -9.93
    
    # challenge: bad airports vs. bad carriers
    flights %>%
      group_by(carrier, dest) %>%
      summarize(mean_delay = mean(arr_delay, na.rm = TRUE)) %>%
      group_by(carrier) %>%
      summarize(mean_delay_mad = mad(mean_delay, na.rm = TRUE)) %>%
      arrange(desc(mean_delay_mad))
    #> # A tibble: 16 x 2
    #>    carrier mean_delay_mad
    #>    <chr>            <dbl>
    #>  1 VX               12.4 
    #>  2 OO               10.5 
    #>  3 YV                8.97
    #>  4 9E                8.20
    #>  5 EV                7.09
    #>  6 DL                7.00
    #>  7 UA                5.04
    #>  8 US                5.03
    #>  9 B6                5.00
    #> 10 WN                4.51
    #> 11 AA                3.31
    #> 12 MQ                2.88
    #> 13 FL                1.55
    #> 14 AS                0   
    #> 15 F9                0   
    #> 16 HA                0
    ```
    
    For the challenge, I calculated the median absolute deviation of average arrival delay by carrier and destination. Higher values indicate a larger spread in the average delays across destinations, meaning these carriers experienced more variation in average delays - for some destinations these carriers experienced longer delays, whereas some destinations arrivals were closer to on time. Lower values mean the carrier experienced similar delays across destinations. **It does not mean these carriers were on time.** It just means they were more consistent. Comparing this table to the first table of average arrival delays could disentangle the effect of bad carriers vs. bad airports.

1.  For each plane, count the number of flights before the first delay 
    of greater than 1 hour.
    
    
    ```r
    flights %>%
      group_by(tailnum) %>%
      mutate(row_num = row_number()) %>%
      filter(arr_delay > 60) %>%
      summarize(first_hour_delay = first(row_num) - 1)
    #> # A tibble: 3,371 x 2
    #>    tailnum first_hour_delay
    #>    <chr>              <dbl>
    #>  1 D942DN                 0
    #>  2 N0EGMQ                 0
    #>  3 N10156                 9
    #>  4 N102UW                33
    #>  5 N104UW                 6
    #>  6 N10575                 0
    #>  7 N105UW                34
    #>  8 N107US                29
    #>  9 N108UW                 9
    #> 10 N109UW                15
    #> # … with 3,361 more rows
    ```
    
    This uses a grouped summary operation. First I group by plane (`tailnum`), then I create a variable that defines the row number within each plane. I then filter the data to only include flights with delays longer than an hour, and use `summarize()` in conjunction with `first()` to find for each plane the `row_num` of the first flight with an 1+ hour delay. I subtract 1 from that value to count the number of flights *before the first delay*, rather than including the first flight with the hour or more delay.

1.  What does the `sort` argument to `count()` do. When might you use it?

    The `sort` argument will sort the results of `count()` in descending order of `n`. You might use this if you plan to `arrange()` the results after completing the count. This saves you a line of code.

## 5.7.1 Exercises

1.  Refer back to the table of useful mutate and filtering functions. 
    Describe how each operation changes when you combine it with grouping.

1.  Which plane (`tailnum`) has the worst on-time record?

    Here I define "on-time" as arriving within 30 minutes of the scheduled arrival time.

    
    ```r
    flights %>%
      group_by(tailnum) %>%
      summarize(prop_on_time = sum(arr_delay <= 30, na.rm = TRUE) / n(),
                mean_arr_delay = mean(arr_delay, na.rm = TRUE),
                flights = n()) %>%
      arrange(prop_on_time, desc(mean_arr_delay))
    #> # A tibble: 4,044 x 4
    #>    tailnum prop_on_time mean_arr_delay flights
    #>    <chr>          <dbl>          <dbl>   <int>
    #>  1 N844MH             0            320       1
    #>  2 N911DA             0            294       1
    #>  3 N922EV             0            276       1
    #>  4 N587NW             0            264       1
    #>  5 N851NW             0            219       1
    #>  6 N928DN             0            201       1
    #>  7 N7715E             0            188       1
    #>  8 N654UA             0            185       1
    #>  9 N427SW             0            157       1
    #> 10 N136DL             0            146       1
    #> # … with 4,034 more rows
    ```

1.  What time of day should you fly if you want to avoid delays as much
    as possible?
    
    
    ```r
    flights %>%
      group_by(hour) %>%
      summarize(arr_delay = sum(arr_delay > 5, na.rm = TRUE) / n()) %>%
      ggplot(aes(x = hour, y = arr_delay)) +
      geom_col()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-63-1.png" width="70%" style="display: block; margin: auto;" />
    
    Avoid flying in the evening to minimize your arrival delay.
    
1.  For each destination, compute the total minutes of delay. For each, 
    flight, compute the proportion of the total delay for its destination.
    
1.  Delays are typically temporally correlated: even once the problem that
    caused the initial delay has been resolved, later flights are delayed 
    to allow earlier flights to leave. Using `lag()` explore how the delay
    of a flight is related to the delay of the immediately preceding flight.
    
    
    ```r
    flights %>%
      group_by(origin) %>%
      arrange(year, month, day, hour, minute) %>%
      mutate(prev_dep_delay = lag(dep_delay)) %>%
      ggplot(aes(x = prev_dep_delay, y = dep_delay)) +
      geom_point() +
      geom_smooth()
    #> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
    #> Warning: Removed 14383 rows containing non-finite values (stat_smooth).
    #> Warning: Removed 14383 rows containing missing values (geom_point).
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-64-1.png" width="70%" style="display: block; margin: auto;" />
    
1.  Look at each destination. Can you find flights that are suspiciously
    fast? (i.e. flights that represent a potential data entry error). Compute
    the air time a flight relative to the shortest flight to that destination.
    Which flights were most delayed in the air?
    
1.  Find all destinations that are flown by at least two carriers. Use that
    information to rank the carriers.

# 7 Exploratory Data Analysis

## 7.3.4 Exercises

1.  Explore the distribution of each of the `x`, `y`, and `z` variables 
    in `diamonds`. What do you learn? Think about a diamond and how you
    might decide which dimension is the length, width, and depth.
    
    
    ```r
    ggplot(diamonds, aes(x)) +
      geom_histogram()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-65-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot(diamonds, aes(y)) +
      geom_histogram()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-65-2.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    ggplot(diamonds, aes(z)) +
      geom_histogram()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-65-3.png" width="70%" style="display: block; margin: auto;" />

1.  Explore the distribution of `price`. Do you discover anything unusual
    or surprising? (Hint: Carefully think about the `binwidth` and make sure
    you try a wide range of values.)
    
    
    ```r
    # default binwidth
    ggplot(diamonds, aes(price)) +
      geom_histogram()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-66-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # binwidth = 100
    ggplot(diamonds, aes(price)) +
      geom_histogram(binwidth = 100) +
      scale_x_continuous(breaks = seq(0, 20000, by = 1000))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-66-2.png" width="70%" style="display: block; margin: auto;" />

    There are far fewer diamonds priced at \$1500 compared to other price points. This is not apparent using the default number of bins.
    
1.  How many diamonds are 0.99 carat? How many are 1 carat? What
    do you think is the cause of the difference?
    
    
    ```r
    ggplot(diamonds, aes(carat)) +
      geom_histogram(binwidth = .01) +
      coord_cartesian(xlim = c(.97, 1.03))
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-67-1.png" width="70%" style="display: block; margin: auto;" />
    
    Around 1500 diamonds are `\(1.00\)` carat, compared to around 30 or so diamonds at `\(.99\)` carat. This could occur because prospective buyers of diamonds, if they are already willing to buy a `\(.99\)` carat diamond will decide it is more aesthetically pleasing to say they bought a `\(1\)` carat diamond so there is less demand for `\(.99\)` carat diamonds.
    
1.  Compare and contrast `coord_cartesian()` vs `xlim()` or `ylim()` when
    zooming in on a histogram. What happens if you leave `binwidth` unset?
    What happens if you try and zoom so only half a bar shows?
    
    
    ```r
    # full plot
    ggplot(diamonds, aes(carat, price)) +
      geom_point() +
      geom_smooth()
    #> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-68-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # xlim
    ggplot(diamonds, aes(carat, price)) +
      geom_point() +
      geom_smooth() +
      xlim(1, 3)
    #> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
    #> Warning: Removed 34912 rows containing non-finite values (stat_smooth).
    #> Warning: Removed 34912 rows containing missing values (geom_point).
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-68-2.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # coord_cartesian
    ggplot(diamonds, aes(carat, price)) +
      geom_point() +
      geom_smooth() +
      coord_cartesian(xlim = c(1, 3))
    #> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-68-3.png" width="70%" style="display: block; margin: auto;" />
    
    By using `xlim()` or `ylim()`, you remove all observations which exceed these values so they are not used to generate the plot. By using `coord_cartesian()`, those values are used to generate the plot and are merely cut off when zooming in. Note the change in the smoothing line in the `xlim()` example because it doesn't have all the data points to calculate the line.

## 7.4.1 Exercises

1.  What happens to missing values in a histogram?  What happens to missing
    values in a bar chart? Why is there a difference?
    
    
    ```r
    ggplot(flights, aes(dep_delay)) +
      geom_histogram()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    #> Warning: Removed 8255 rows containing non-finite values (stat_bin).
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-69-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # change AA to NA
    flights %>%
      mutate(carrier = ifelse(carrier == "AA", NA, carrier)) %>%
      ggplot(aes(carrier)) +
      geom_bar()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-69-2.png" width="70%" style="display: block; margin: auto;" />
    
    Histograms omit missing values, whereas bar charts draw them as a separate category. For continuous variables, like in a histogram, there is no meaningful location to draw missing values. On the far left? Far right? Middle? But for bar charts, which are used for categorical variables, you could draw them as a distinct bar; by default it can be located anywhere on the chart (conventionally it is drawn on the right side). You can override this default to completely remove missing values from the chart if you prefer.

1.  What does `na.rm = TRUE` do in `mean()` and `sum()`?

    It strips missing values before computing the statistic.

## 7.5.1.1 Exercises

1.  Use what you've learned to improve the visualisation of the departure times
    of cancelled vs. non-cancelled flights.
    
    
    ```r
    # original chart
    flights %>% 
      mutate(
        cancelled = is.na(dep_time),
        sched_hour = sched_dep_time %/% 100,
        sched_min = sched_dep_time %% 100,
        sched_dep_time = sched_hour + sched_min / 60
        ) %>%
      ggplot(mapping = aes(sched_dep_time)) + 
      geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-70-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # revised chart
    flights %>% 
      mutate(
        cancelled = is.na(dep_time),
        sched_hour = sched_dep_time %/% 100,
        sched_min = sched_dep_time %% 100,
        sched_dep_time = sched_hour + sched_min / 60
        ) %>%
      ggplot(aes(x = sched_dep_time, y = stat(density), color = cancelled)) + 
      geom_freqpoly(binwidth = 1/4)
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-70-2.png" width="70%" style="display: block; margin: auto;" />

1.  What variable in the diamonds dataset is most important for predicting
    the price of a diamond? How is that variable correlated with cut?
    Why does the combination of those two relationships lead to lower quality
    diamonds being more expensive?
    
    
    ```r
    ggplot(diamonds, aes(carat, price)) +
      geom_point() +
      geom_smooth()
    #> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-71-1.png" width="70%" style="display: block; margin: auto;" />

    Carat size is the most important predictor of price.

    
    ```r
    ggplot(diamonds, aes(cut, carat)) +
      geom_boxplot()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-72-1.png" width="70%" style="display: block; margin: auto;" />
    
    This boxplot visualizes the relationship between cut and carat. On average, fair and good cut diamonds are larger than premium and ideal cuts. If carat size is the more dominant predictor of price, then some larger good cut diamonds will be more expensive than smaller ideal cut diamonds.

1.  Install the `ggstance` package, and create a horizontal boxplot.
    How does this compare to using `coord_flip()`?
    
    
    ```r
    install.packages("ggstance")
    ```
    
    To create a horizontal layer in `ggplot2` with `coord_flip()`, you have to supply aesthetics as if they were to be drawn vertically:
    
    
    ```r
    ggplot(diamonds, aes(cut, carat)) +
      geom_boxplot() +
      coord_flip()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-74-1.png" width="70%" style="display: block; margin: auto;" />
    
    In `ggstance`, you supply aesthetics in their natural order:
    
    
    ```r
    library(ggstance)
    #> 
    #> Attaching package: 'ggstance'
    #> The following objects are masked from 'package:ggplot2':
    #> 
    #>     geom_errorbarh, GeomErrorbarh
    ggplot(diamonds, aes(carat, cut)) +
      geom_boxploth()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-75-1.png" width="70%" style="display: block; margin: auto;" />

1.  One problem with boxplots is that they were developed in an era of 
    much smaller datasets and tend to display a prohibitively large
    number of "outlying values". One approach to remedy this problem is
    the letter value plot. Install the `lvplot` package, and try using
    `geom_lv()` to display the distribution of price vs cut. What
    do you learn? How do you interpret the plots?

    
    ```r
    devtools::install_github("hadley/lvplot")
    ```
    
    
    ```r
    library(lvplot)
    
    # with boxplot
    ggplot(diamonds, aes(cut, price)) +
      geom_boxplot()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-77-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # with lvplot
    ggplot(diamonds, aes(cut, price)) +
      geom_lv()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-77-2.png" width="70%" style="display: block; margin: auto;" />
    
1.  Compare and contrast `geom_violin()` with a facetted `geom_histogram()`,
    or a coloured `geom_freqpoly()`. What are the pros and cons of each 
    method?
    
    
    ```r
    # geom_violin
    ggplot(diamonds, aes(cut, price)) +
      geom_violin()
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-78-1.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # faceted geom_histogram
    ggplot(diamonds, aes(price)) +
      geom_histogram() +
      facet_grid(. ~ cut)
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-78-2.png" width="70%" style="display: block; margin: auto;" />
    
    ```r
    
    # colored geom_freqpoly
    ggplot(diamonds, aes(price, color = cut)) +
      geom_freqpoly()
    #> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
    ```
    
    <img src="/r4ds/_index_files/figure-html/unnamed-chunk-78-3.png" width="70%" style="display: block; margin: auto;" />

1.  If you have a small dataset, it's sometimes useful to use `geom_jitter()`
    to see the relationship between a continuous and categorical variable.
    The `ggbeeswarm` package provides a number of methods similar to 
    `geom_jitter()`. List them and briefly describe what each one does.

# 10 Tibbles

## 10.5 Exercises

1.  How can you tell if an object is a tibble? (Hint: try printing `mtcars`,
    which is a regular data frame). 
    
    
    ```r
    # data frame
    print(mtcars)
    #>                      mpg cyl  disp  hp drat   wt qsec vs am gear carb
    #> Mazda RX4           21.0   6 160.0 110 3.90 2.62 16.5  0  1    4    4
    #> Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.88 17.0  0  1    4    4
    #> Datsun 710          22.8   4 108.0  93 3.85 2.32 18.6  1  1    4    1
    #> Hornet 4 Drive      21.4   6 258.0 110 3.08 3.21 19.4  1  0    3    1
    #> Hornet Sportabout   18.7   8 360.0 175 3.15 3.44 17.0  0  0    3    2
    #> Valiant             18.1   6 225.0 105 2.76 3.46 20.2  1  0    3    1
    #> Duster 360          14.3   8 360.0 245 3.21 3.57 15.8  0  0    3    4
    #> Merc 240D           24.4   4 146.7  62 3.69 3.19 20.0  1  0    4    2
    #> Merc 230            22.8   4 140.8  95 3.92 3.15 22.9  1  0    4    2
    #> Merc 280            19.2   6 167.6 123 3.92 3.44 18.3  1  0    4    4
    #> Merc 280C           17.8   6 167.6 123 3.92 3.44 18.9  1  0    4    4
    #> Merc 450SE          16.4   8 275.8 180 3.07 4.07 17.4  0  0    3    3
    #> Merc 450SL          17.3   8 275.8 180 3.07 3.73 17.6  0  0    3    3
    #> Merc 450SLC         15.2   8 275.8 180 3.07 3.78 18.0  0  0    3    3
    #> Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.25 18.0  0  0    3    4
    #> Lincoln Continental 10.4   8 460.0 215 3.00 5.42 17.8  0  0    3    4
    #> Chrysler Imperial   14.7   8 440.0 230 3.23 5.34 17.4  0  0    3    4
    #> Fiat 128            32.4   4  78.7  66 4.08 2.20 19.5  1  1    4    1
    #> Honda Civic         30.4   4  75.7  52 4.93 1.61 18.5  1  1    4    2
    #> Toyota Corolla      33.9   4  71.1  65 4.22 1.83 19.9  1  1    4    1
    #> Toyota Corona       21.5   4 120.1  97 3.70 2.46 20.0  1  0    3    1
    #> Dodge Challenger    15.5   8 318.0 150 2.76 3.52 16.9  0  0    3    2
    #> AMC Javelin         15.2   8 304.0 150 3.15 3.44 17.3  0  0    3    2
    #> Camaro Z28          13.3   8 350.0 245 3.73 3.84 15.4  0  0    3    4
    #> Pontiac Firebird    19.2   8 400.0 175 3.08 3.85 17.1  0  0    3    2
    #> Fiat X1-9           27.3   4  79.0  66 4.08 1.94 18.9  1  1    4    1
    #> Porsche 914-2       26.0   4 120.3  91 4.43 2.14 16.7  0  1    5    2
    #> Lotus Europa        30.4   4  95.1 113 3.77 1.51 16.9  1  1    5    2
    #> Ford Pantera L      15.8   8 351.0 264 4.22 3.17 14.5  0  1    5    4
    #> Ferrari Dino        19.7   6 145.0 175 3.62 2.77 15.5  0  1    5    6
    #> Maserati Bora       15.0   8 301.0 335 3.54 3.57 14.6  0  1    5    8
    #> Volvo 142E          21.4   4 121.0 109 4.11 2.78 18.6  1  1    4    2
    
    # tibble
    print(as_tibble(mtcars))
    #> # A tibble: 32 x 11
    #>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
    #>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    #>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
    #>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
    #>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
    #>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
    #>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
    #>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
    #>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
    #>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
    #>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
    #> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
    #> # … with 22 more rows
    ```
    
    A data frame will print the entire contents. A tibble will only print (by default) the first 10 rows and as many columns as will fit in the console.

1.  Compare and contrast the following operations on a `data.frame` and 
    equivalent tibble. What is different? Why might the default data frame
    behaviours cause you frustration?
    
    
    ```r
    # on a data frame
    df <- data.frame(abc = 1, xyz = "a")
    df$x
    #> [1] a
    #> Levels: a
    df[, "xyz"]
    #> [1] a
    #> Levels: a
    df[, c("abc", "xyz")]
    #>   abc xyz
    #> 1   1   a
    
    # on a tibble
    df <- tibble(abc = 1, xyz = "a")
    df$x
    #> Warning: Unknown or uninitialised column: 'x'.
    #> NULL
    df[, "xyz"]
    #> # A tibble: 1 x 1
    #>   xyz  
    #>   <chr>
    #> 1 a
    df[, c("abc", "xyz")]
    #> # A tibble: 1 x 2
    #>     abc xyz  
    #>   <dbl> <chr>
    #> 1     1 a
    ```
    
    * Tibbles never do partial matching; data frames do.
    * Subsetting tibbles using `[[` will always return a tibble; subsetting data frames using `[[` can potentially return a vector.
    
        ![](images/gump.jpg)

1.  If you have the name of a variable stored in an object, e.g. `var <- "mpg"`,
    how can you extract the reference variable from a tibble?
    
    
    ```r
    var <- "hwy"
    mpg[[var]]
    #>   [1] 29 29 31 30 26 26 27 26 25 28 27 25 25 25 25 24 25 23 20 15 20 17 17
    #>  [24] 26 23 26 25 24 19 14 15 17 27 30 26 29 26 24 24 22 22 24 24 17 22 21
    #>  [47] 23 23 19 18 17 17 19 19 12 17 15 17 17 12 17 16 18 15 16 12 17 17 16
    #>  [70] 12 15 16 17 15 17 17 18 17 19 17 19 19 17 17 17 16 16 17 15 17 26 25
    #>  [93] 26 24 21 22 23 22 20 33 32 32 29 32 34 36 36 29 26 27 30 31 26 26 28
    #> [116] 26 29 28 27 24 24 24 22 19 20 17 12 19 18 14 15 18 18 15 17 16 18 17
    #> [139] 19 19 17 29 27 31 32 27 26 26 25 25 17 17 20 18 26 26 27 28 25 25 24
    #> [162] 27 25 26 23 26 26 26 26 25 27 25 27 20 20 19 17 20 17 29 27 31 31 26
    #> [185] 26 28 27 29 31 31 26 26 27 30 33 35 37 35 15 18 20 20 22 17 19 18 20
    #> [208] 29 26 29 29 24 44 29 26 29 29 29 29 23 24 44 41 29 26 28 29 29 29 28
    #> [231] 29 26 26 26
    ```

1.  Practice referring to non-syntactic names in the following data frame by:

    
    ```r
    annoying <- tibble(
      `1` = 1:10,
      `2` = `1` * 2 + rnorm(length(`1`))
    )
    ```

    1.  Extracting the variable called `1`.
    
        
        ```r
        annoying$`1`
        #>  [1]  1  2  3  4  5  6  7  8  9 10
        ```

    1.  Plotting a scatterplot of `1` vs `2`.

        
        ```r
        ggplot(annoying, aes(`1`, `2`)) +
          geom_point()
        ```
        
        <img src="/r4ds/_index_files/figure-html/unnamed-chunk-84-1.png" width="70%" style="display: block; margin: auto;" />

    1.  Creating a new column called `3` which is `2` divided by `1`.
        
        
        ```r
        (annoying <- mutate(annoying, `3` = `2` / `1`))
        #> # A tibble: 10 x 3
        #>      `1`   `2`   `3`
        #>    <int> <dbl> <dbl>
        #>  1     1  3.18  3.18
        #>  2     2  4.64  2.32
        #>  3     3  5.37  1.79
        #>  4     4  7.19  1.80
        #>  5     5  9.14  1.83
        #>  6     6  9.83  1.64
        #>  7     7 12.6   1.80
        #>  8     8 15.5   1.94
        #>  9     9 17.4   1.94
        #> 10    10 19.8   1.98
        ```

    1.  Renaming the columns to `one`, `two` and `three`.

        
        ```r
        rename(annoying,
               one = `1`,
               two = `2`,
               three = `3`)
        #> # A tibble: 10 x 3
        #>      one   two three
        #>    <int> <dbl> <dbl>
        #>  1     1  3.18  3.18
        #>  2     2  4.64  2.32
        #>  3     3  5.37  1.79
        #>  4     4  7.19  1.80
        #>  5     5  9.14  1.83
        #>  6     6  9.83  1.64
        #>  7     7 12.6   1.80
        #>  8     8 15.5   1.94
        #>  9     9 17.4   1.94
        #> 10    10 19.8   1.98
        ```

1.  What does `tibble::enframe()` do? When might you use it?

    `enframe()` is a helper function that converts named atomic vectors or lists to two-column data frames. You might use it if you have data stored in a named vector and you want to add it to a data frame and preserve both the name attribute and the actual value.
    
    
    ```r
    enframe(c(a = 5, b = 7))
    #> # A tibble: 2 x 2
    #>   name  value
    #>   <chr> <dbl>
    #> 1 a         5
    #> 2 b         7
    ```

1.  What option controls how many additional column names are printed
    at the footer of a tibble?
    
    `getOption("tibble.max_extra_cols")`

## Session Info



```r
devtools::session_info()
#> ─ Session info ──────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 3.5.2 (2018-12-20)
#>  os       macOS Mojave 10.14.3        
#>  system   x86_64, darwin15.6.0        
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       America/Chicago             
#>  date     2019-03-20                  
#> 
#> ─ Packages ──────────────────────────────────────────────────────────────
#>  package     * version date       lib source        
#>  assertthat    0.2.0   2017-04-11 [2] CRAN (R 3.5.0)
#>  backports     1.1.3   2018-12-14 [2] CRAN (R 3.5.0)
#>  blogdown      0.11    2019-03-11 [1] CRAN (R 3.5.2)
#>  bookdown      0.9     2018-12-21 [1] CRAN (R 3.5.0)
#>  callr         3.2.0   2019-03-15 [2] CRAN (R 3.5.2)
#>  cli           1.1.0   2019-03-19 [1] CRAN (R 3.5.2)
#>  crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.0)
#>  desc          1.2.0   2018-05-01 [2] CRAN (R 3.5.0)
#>  devtools      2.0.1   2018-10-26 [1] CRAN (R 3.5.1)
#>  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.0)
#>  evaluate      0.13    2019-02-12 [2] CRAN (R 3.5.2)
#>  fs            1.2.6   2018-08-23 [1] CRAN (R 3.5.0)
#>  glue          1.3.1   2019-03-12 [2] CRAN (R 3.5.2)
#>  here          0.1     2017-05-28 [2] CRAN (R 3.5.0)
#>  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.0)
#>  knitr         1.22    2019-03-08 [2] CRAN (R 3.5.2)
#>  magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.0)
#>  memoise       1.1.0   2017-04-21 [2] CRAN (R 3.5.0)
#>  pkgbuild      1.0.2   2018-10-16 [1] CRAN (R 3.5.0)
#>  pkgload       1.0.2   2018-10-29 [1] CRAN (R 3.5.0)
#>  prettyunits   1.0.2   2015-07-13 [2] CRAN (R 3.5.0)
#>  processx      3.3.0   2019-03-10 [2] CRAN (R 3.5.2)
#>  ps            1.3.0   2018-12-21 [2] CRAN (R 3.5.0)
#>  R6            2.4.0   2019-02-14 [1] CRAN (R 3.5.2)
#>  Rcpp          1.0.0   2018-11-07 [1] CRAN (R 3.5.0)
#>  remotes       2.0.2   2018-10-30 [1] CRAN (R 3.5.0)
#>  rlang         0.3.1   2019-01-08 [1] CRAN (R 3.5.2)
#>  rmarkdown     1.12    2019-03-14 [1] CRAN (R 3.5.2)
#>  rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.5.0)
#>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.0)
#>  stringi       1.3.1   2019-02-13 [1] CRAN (R 3.5.2)
#>  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.5.2)
#>  testthat      2.0.1   2018-10-13 [2] CRAN (R 3.5.0)
#>  usethis       1.4.0   2018-08-14 [1] CRAN (R 3.5.0)
#>  withr         2.1.2   2018-03-15 [2] CRAN (R 3.5.0)
#>  xfun          0.5     2019-02-20 [1] CRAN (R 3.5.2)
#>  yaml          2.2.0   2018-07-25 [2] CRAN (R 3.5.0)
#> 
#> [1] /Users/soltoffbc/Library/R/3.5/library
#> [2] /Library/Frameworks/R.framework/Versions/3.5/Resources/library
```

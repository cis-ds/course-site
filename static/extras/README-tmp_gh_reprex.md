``` r
library(tidyverse)
count(diamonds, colour)
#> Error in `group_by()`:
#> ! Must group by variables found in `.data`.
#> ✖ Column `colour` is not found.

#> Backtrace:
#>     ▆
#>  1. ├─dplyr::count(diamonds, colour)
#>  2. └─dplyr:::count.data.frame(diamonds, colour)
#>  3.   ├─dplyr::group_by(x, ..., .add = TRUE, .drop = .drop)
#>  4.   └─dplyr:::group_by.data.frame(x, ..., .add = TRUE, .drop = .drop)
#>  5.     └─dplyr::group_by_prepare(.data, ..., .add = .add, caller_env = caller_env())
#>  6.       └─rlang::abort(bullets, call = error_call)
```

<sup>Created on 2022-08-22 by the [reprex package](https://reprex.tidyverse.org) (v2.0.1.9000)</sup>

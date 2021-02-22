``` r
library(tidyverse)
count(diamonds, colour)
#> Error: Must group by variables found in `.data`.
#> * Column `colour` is not found.
```

<sup>Created on 2020-12-15 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>


<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyvalidate <a href="https://angelfelizr.github.io/tidyvalidate/"><img src="man/figures/logo.png" align="right" height="139" alt="tidyvalidate website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/AngelFelizR/tidyvalidate/branch/master/graph/badge.svg)](https://app.codecov.io/gh/AngelFelizR/tidyvalidate?branch=master)
[![R-CMD-check](https://github.com/AngelFelizR/tidyvalidate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AngelFelizR/tidyvalidate/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `tidyvalidate` is to simplify the workflow of the `validate`
package to work with data.frames by providing tools to manage the usage
of ‘confront’, ‘validator’, ‘violating’, and ‘summary’ functions. It
also streamlines the integration with base R’s ‘stop’ and ‘warning’
functions, enhancing error handling and reporting.

## Installation

You can install the development version of tidyvalidate like so:

``` r
#install.packages("pak")
pak::pak("AngelFelizR/tidyvalidate")
```

## Example - validate_rules

The `validate_rules()` functions can find errors at column and row level
by passing a list with the **summary** and **row_level_errors**.

``` r
library(tidyvalidate)

simple_validation <-
  validate_rules(mtcars,
                 mpg_string = is.character(mpg),
                 hp_numeric = is.numeric(hp),
                 mpg_low = mpg > 15)

simple_validation
#> $summary
#>          name items passes fails   nNA  error warning
#>        <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_string     1      0     1     0  FALSE   FALSE
#> 2: hp_numeric     1      1     0     0  FALSE   FALSE
#> 3:    mpg_low    32     26     6     0  FALSE   FALSE
#> 
#> $row_level_errors
#> $row_level_errors$mpg_low
#>    Broken Rule   mpg
#>         <char> <num>
#> 1:     mpg_low  14.3
#> 2:     mpg_low  10.4
#> 3:     mpg_low  10.4
#> 4:     mpg_low  14.7
#> 5:     mpg_low  13.3
#> 6:     mpg_low  15.0
```

## Example - action_if_problem

After finding a problem you can show an **error** message.

``` r
try({
  validate_rules(mtcars,
                 mpg_string = is.character(mpg),
                 hp_numeric = is.numeric(hp),
                 mpg_low = mpg > 15) |>
    action_if_problem("We shound't have cars with low mpg")
})
#> [1] "We shound't have cars with low mpg"
#>          name items passes fails   nNA  error warning
#>        <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_string     1      0     1     0  FALSE   FALSE
#> 2:    mpg_low    32     26     6     0  FALSE   FALSE
#> Error in action_if_problem(validate_rules(mtcars, mpg_string = is.character(mpg),  : 
#>   We shound't have cars with low mpg
```

Or just show a **warning**.

``` r
validate_rules(mtcars,
               mpg_string = is.character(mpg),
               hp_numeric = is.numeric(hp),
               mpg_low = mpg > 15) |>
  action_if_problem("We shound't have cars with low mpg",
                    problem_action = "warning")
#> [1] "We shound't have cars with low mpg"
#>          name items passes fails   nNA  error warning
#>        <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_string     1      0     1     0  FALSE   FALSE
#> 2:    mpg_low    32     26     6     0  FALSE   FALSE
#> Warning in action_if_problem(validate_rules(mtcars, mpg_string =
#> is.character(mpg), : We shound't have cars with low mpg
```

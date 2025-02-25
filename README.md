
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyvalidate <a href="https://angelfelizr.github.io/tidyvalidate/"><img src="man/figures/logo.png" align="right" height="139" alt="tidyvalidate website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/AngelFelizR/tidyvalidate/branch/master/graph/badge.svg)](https://app.codecov.io/gh/AngelFelizR/tidyvalidate?branch=master)
[![R-CMD-check](https://github.com/AngelFelizR/tidyvalidate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AngelFelizR/tidyvalidate/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

tidyvalidate simplifies data validation in R by providing an intuitive
interface to the powerful `validate` package. It helps ensure data
quality by making it easy to:

- Write clear, expressive validation rules
- Check both column-level and row-level conditions
- Get detailed reports of validation failures
- Integrate validation checks into your data pipeline

The package streamlines common validation tasks while leveraging the
robust foundation of the `validate` package and R’s error handling
system.

## Installation

You can install the development version of tidyvalidate from GitHub:

``` r
# Install pak if you haven't already
# install.packages("pak")

# Install tidyvalidate
pak::pak("AngelFelizR/tidyvalidate")
```

## Quick Start

### Basic Validation

Let’s validate some data from the built-in `mtcars` dataset:

``` r
library(tidyvalidate)

# Define and run validations
validation_results <- validate_rules(
  mtcars,
  # Column type validations
  mpg_is_numeric = is.numeric(mpg),
  hp_is_numeric = is.numeric(hp),
  
  # Business rule validation
  mpg_minimum = mpg > 15
)

# View results
validation_results
#> $summary
#>              name items passes fails   nNA  error warning
#>            <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_is_numeric     1      1     0     0  FALSE   FALSE
#> 2:  hp_is_numeric     1      1     0     0  FALSE   FALSE
#> 3:    mpg_minimum    32     26     6     0  FALSE   FALSE
#> 
#> $row_level_errors
#> $row_level_errors$mpg_minimum
#>    Broken Rule   mpg
#>         <char> <num>
#> 1: mpg_minimum  14.3
#> 2: mpg_minimum  10.4
#> 3: mpg_minimum  10.4
#> 4: mpg_minimum  14.7
#> 5: mpg_minimum  13.3
#> 6: mpg_minimum  15.0
```

The results show: - A summary of all validations - Detailed information
about which rows failed the `mpg_minimum` check

### Taking Action on Validation Failures

You can automatically handle validation failures in two ways:

#### 1. Stop Execution on Failure

``` r
try({
  validate_rules(mtcars,
    mpg_minimum = mpg > 15
  ) |>
    action_if_problem(
      "Critical: Found cars with MPG below minimum threshold"
    )
})
#> [1] "Critical: Found cars with MPG below minimum threshold"
#>           name items passes fails   nNA  error warning
#>         <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_minimum    32     26     6     0  FALSE   FALSE
#> Error in action_if_problem(validate_rules(mtcars, mpg_minimum = mpg >  : 
#>   Critical: Found cars with MPG below minimum threshold
```

#### 2. Continue with Warning

``` r
validation_results <- validate_rules(mtcars,
    mpg_minimum = mpg > 15
  ) |>
  action_if_problem(
    "Advisory: Some cars have low MPG values",
    problem_action = "warning"
  )
#> [1] "Advisory: Some cars have low MPG values"
#>           name items passes fails   nNA  error warning
#>         <char> <int>  <int> <int> <int> <lgcl>  <lgcl>
#> 1: mpg_minimum    32     26     6     0  FALSE   FALSE
#> Warning in action_if_problem(validate_rules(mtcars, mpg_minimum = mpg > :
#> Advisory: Some cars have low MPG values
```

## Key Features

- **Simple Interface**: Write validation rules using familiar R syntax
- **Comprehensive Results**: Get both summary statistics and row-level
  details
- **Flexible Actions**: Choose between warnings and errors based on
  severity
- **Pipeline Integration**: Works seamlessly with the pipe operator
- **Detailed Reporting**: Identify exactly which rows failed validation

## Learn More

- Visit our [website](https://angelfelizr.github.io/tidyvalidate/) for
  full documentation
- Read the [Getting
  Started](https://angelfelizr.github.io/tidyvalidate/articles/tidyvalidate.html)
  guide
- Check out the
  [Reference](https://angelfelizr.github.io/tidyvalidate/reference/index.html)
  section for detailed function documentation

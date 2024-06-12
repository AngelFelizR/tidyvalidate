#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table :=
#' @importFrom data.table is.data.table
#' @importFrom data.table setattr
#' @importFrom data.table setDT
#' @importFrom stringr str_extract_all
#' @importFrom stringr str_replace_all
#' @importFrom validate confront
#' @importFrom validate summary
#' @importFrom validate validator
#' @importFrom validate violating
## usethis namespace: end
NULL

# Solving Global Variables problem

utils::globalVariables(c(

  ## From data.table
  ".SD",

  ## From action_if_problem
  "fails",

  ## From validate_rules
  "nNA",
  "name",
  "items",
  "fails",
  "Broken Rule"

))

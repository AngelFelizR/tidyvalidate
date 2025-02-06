#' Validate Data Frame Values Against Business Rules
#'
#' A high-level wrapper around the `validate` package that performs data validation
#' checks against a set of user-defined business rules. The function accepts a data frame
#' and a set of validation rules, then returns both a summary of validation results and
#' detailed information about any violations at the row level.
#'
#' @param df A data.frame or data.table containing the data to validate
#' @param ... Validation rules expressed as named R expressions (e.g., "age_check" = age >= 18)
#' @param env A list of variables to be used within the validation rules. These variables
#'           can be referenced directly in the rule expressions (e.g., list(min_age = 18))
#' @param keep_rl_cols Character vector specifying additional columns to include in the
#'                    row-level error output, besides those used in the validation rules
#' @param select_rl_rules Character vector specifying which row-level rules to analyze.
#'                       If NULL (default), analyzes all failing rules
#'
#' @return A list containing two elements:
#'   \itemize{
#'     \item summary: A data.table containing validation results for all rules, including:
#'       \itemize{
#'         \item name: The name of the validation rule
#'         \item items: Number of items checked
#'         \item passes: Number of passing checks
#'         \item fails: Number of failing checks
#'         \item nNA: Number of NA values encountered
#'       }
#'     \item row_level_errors: A list of data.tables, one for each failing rule, containing:
#'       \itemize{
#'         \item Broken Rule: The name of the failed validation rule
#'         \item Columns used in the validation rule
#'         \item Additional columns specified in keep_rl_cols
#'       }
#'   }
#'
#' @details
#' The function provides two key benefits:
#' 1. It simplifies the process of validating data against multiple business rules
#' 2. It makes it easy to identify specific rows that violate each rule
#'
#' The function will stop with an error if any validation rule returns NA values,
#' as these are considered invalid results rather than rule violations.
#'
#' @examples
#' # Validate car data against mpg and horsepower rules
#' validation_results <- data.table::as.data.table(mtcars, keep.rownames = "Car Name") |>
#'   validate_rules(
#'     "mpg_minimum" = mpg > min_mpg,
#'     "hp_maximum" = hp < 200,
#'     env = list(min_mpg = 15),
#'     keep_rl_cols = "Car Name"
#'   )
#'
#' # View summary of all rules
#' validation_results$summary
#'
#' # View specific rows that violated each rule
#' validation_results$row_level_errors
#'
#' @seealso
#' \code{\link[validate]{validator}}, \code{\link[validate]{confront}}
#'
#' @export

validate_rules = function(df,
                          ...,
                          env = list(),
                          keep_rl_cols = NULL,
                          select_rl_rules = NULL){

  ## Confirming class before continue
  if(data.table::is.data.table(df)){
    df = as.data.frame(df)
  }

  ## Making the validation
  confront_result =
    validate::confront(df,
                       x = validate::validator(...),
                       ref = env)


  ## Defining the table to explore
  summary_result = validate::summary(confront_result)

  ## We don't define name as key as
  ## Validate package really in the order
  ## to return the violations later
  data.table::setDT(summary_result)

  ## We cannot allow reporting NA as valid values
  na_rules = summary_result[nNA > 0, name]
  if(length(na_rules) > 0){

    stop(paste("The following rules are returning NA:",
               paste0(na_rules, collapse = ", ")))

  }


  ## Defining the row level rules to extract

  if(!is.null(select_rl_rules)){

    valid_row_level_rules = summary_result[items == nrow(df), name]
    row_level_rules =  intersect(valid_row_level_rules, select_rl_rules)

    if(length(row_level_rules) == 0L){
      stop(paste("Please select a valid row rule:",
                 paste0(valid_row_level_rules, collapse = ", ")))
    }

  }else{

    row_level_rules =  summary_result[items == nrow(df) & fails > 0, name]

  }


  ## If the is not more problems to check
  ## we can end the function here
  if(length(row_level_rules) == 0L){

    final_list = list(
      summary = summary_result[, !c("expression")],
      row_level_errors = NULL
    )

    return(final_list)
  }


  ## Creating a pattern to extract
  ## any column listed in the original table
  col_pattern =
    c("!", "?", "\\", "(", ")", "{",
      "}", "$", "^",  "+", "*", "|") |>
    paste0("\\", a = _) |>
    paste0(collapse = "|") |>
    stringr::str_replace_all(string = names(df), replacement = ".")  |>
    paste0(collapse = "|")


  ## Adding rule name as name before calling lapply to create the list
  data.table::setattr(row_level_rules, "names", row_level_rules)

  ## Creating a list with all cases to correct at row level
  row_level_errors =
    lapply(row_level_rules,
           df_used = df,
           pattern = col_pattern,
           confront_list = confront_result,
           summary_dt = summary_result,
           FUN = function(rule, df_used, pattern, confront_list, summary_dt){

      error_rows = validate::violating(df_used, confront_result[rule])

      data.table::setDT(error_rows)

      error_rows[, `Broken Rule` := rule]

      cols_to_keep =
        summary_dt[rule,
                   on = "name",
                   j = expression] |>
        stringr::str_extract_all(pattern = pattern) |>
        unlist() |>
        c("Broken Rule", keep_rl_cols, a = _) |>
        unique()

      return(error_rows[, .SD, .SDcols = cols_to_keep])

    })


  final_list = list(
    ## As we advance in complexity the expressions gets to hard to be read
    summary = summary_result[, !c("expression")],
    row_level_errors = row_level_errors
  )


  return(final_list)

}

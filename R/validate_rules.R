#' Validate domain knowing in a data.frame
#'
#' This function if a wrappers from many utilities from the validate package.
#'
#' @param df A data.frame or data.table to perform the analysis.
#' @inheritParams validate::validator
#' @param env A list with all the variables we want to make available in the validation rules.
#' @param keep_rl_cols Defining the columns to keep all data.table of broken row level rules.
#' @param select_rl_rules Defining which row level rules to return as data.table in the row_level_errors element.
#'
#' @return
#' This function return a list of 2 elements:
#' - summary: Return data.table with the result of all checks.
#' - row_level_errors: Return a list of data.frames containing the column **Broken Rule**, the columns listed in the `keep_rl_cols` and the columns used to perform the validation.
#'
#' @export
#'
#' @examples
#'validation_list <-
#'   data.table::as.data.table(mtcars,
#'                             keep.rownames = "Car (Name)") |>
#'   validate_rules("mpg low" = mpg > min_mpg,
#'                  "hp high" = hp < 200,
#'                  env = list(min_mpg = 15),
#'                  keep_rl_cols = "Car (Name)")
#'
#' names(validation_list)
#'
#' validation_list$summary
#'
#' validation_list$row_level_errors

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

#' Handle Validation Rule Violations with Custom Actions
#'
#' Takes the results of data validation checks and performs a specified action
#' (either stopping execution or raising a warning) when validation rules are violated.
#' The function provides detailed feedback about which rules failed before taking the
#' specified action.
#'
#' @param x A list containing validation results, typically the output from
#'          [validate_rules()]. Must contain a 'summary' element with columns
#'          for 'fails' and other validation metrics.
#' @param message_text Character string containing the message to display when
#'                     violations are found. This message will appear in both the
#'                     console output and the error/warning.
#' @param problem_action Character string specifying the action to take when
#'                      violations are found. Must be either "stop" (to halt
#'                      execution with an error) or "warning" (to continue
#'                      execution after showing a warning).
#'
#' @return Invisibly returns the input list `x`. Note that if problem_action
#'         is "stop" and violations are found, execution will halt before
#'         returning.
#'
#' @details
#' The function performs these steps:
#' 1. Checks if any validation rules were violated (fails > 0)
#' 2. If violations exist:
#'    - Prints the provided message_text
#'    - Displays a summary of only the failed rules
#'    - Either stops execution or raises a warning based on problem_action
#' 3. If no violations exist, silently returns the input
#'
#' This function is particularly useful in data processing pipelines where you
#' want to ensure data quality before proceeding with further analysis.
#'
#' @examples
#' # Example showing how to stop execution on validation failures
#' try({
#'   validate_rules(mtcars, "hp_limit" = hp < 200) |>
#'     action_if_problem(
#'       message_text = "Validation failed: Some cars exceed HP limit",
#'       problem_action = "stop"
#'     )
#' })
#'
#' # Example showing how to continue with a warning
#' validation_results <- validate_rules(mtcars, "hp_limit" = hp < 200) |>
#'   action_if_problem(
#'     message_text = "Warning: Some cars exceed HP limit",
#'     problem_action = "warning"
#'   )
#'
#' @seealso
#' \code{\link{validate_rules}} for creating the validation results this
#' function processes
#'
#' @export

action_if_problem = function(x,
                             message_text,
                             problem_action = c("stop", "warning")){

  if(sum(x$summary$fails) != 0){

    action_fun =
      match.arg(problem_action) |>
      switch ("stop" = stop,
              "warning" = warning)

    print(message_text)
    print(x$summary[fails != 0, ])
    action_fun(message_text)
  }

  invisible(x)

}


#' Stop or raise a warning if any rule is not met
#'
#' After checking the rules in the data.frame, this function will print
#' the important cases and stop or raise an alert based on the `problem_action` argument.
#'
#' @param x A list containing the summary from [validate_rules()].
#' @param message_text The message to display when applying the action.
#' @param problem_action Select if you want to display a warning or stop the code.
#'
#' @return The list passed as the first argument.
#' @export
#'
#' @examples
#' # Shows an error
#' try({
#'   validate_rules(mtcars, "hp high" = hp < 200) |>
#'     action_if_problem("Here is the error", "stop")
#' })
#'
#' # Shows a warning
#' validate_rules(mtcars, "hp high" = hp < 200) |>
#'   action_if_problem("Here is the warning", "warning")

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


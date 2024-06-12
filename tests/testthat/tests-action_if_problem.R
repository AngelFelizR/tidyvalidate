test_that("It's produting the error",{

  ## The error is working
  expect_error({
    validate_rules(mtcars,
                   "hp high" = hp < 200,
                   mpg_numeric = is.double(mpg)) |>
      action_if_problem("Here is the error", "stop")
  },
  regexp = "Here is the error",
  fixed = TRUE)


  ## The error is working
  expect_no_error({
    validate_rules(mtcars,
                   "hp high" = is.double(hp),
                   mpg_numeric = is.double(mpg)) |>
      action_if_problem("Here is the error", "stop")
  })

})


test_that("It's produting the warning",{

  ## Shows warning
  expect_warning({
    result =
      validate_rules(mtcars,
                     "hp high" = hp < 200,
                     mpg_numeric = is.double(mpg)) |>
      action_if_problem("Here is the warning", "warning")
  },
  regexp = "Here is the warning",
  fixed = TRUE)


  ## Not show warning
  expect_no_warning({
    validate_rules(mtcars,
                   "hp high" = is.double(hp),
                   mpg_numeric = is.double(mpg)) |>
      action_if_problem("Here is the warning", "warning")
  })


  ## It's reporting the original object
  expect_equal(names(result), c("summary", "row_level_errors"))

})

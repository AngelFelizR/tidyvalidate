test_that("It reports problems at general level",{

  validation_list =
    validate_rules(mtcars,
                   # A satisfied rule
                   "cyl|num" = is.numeric(cyl),
                   # A broken rule
                   "mpg|string" = is.character(mpg))

  # It report the error
  expect_equal(validation_list$summary$fails, c(0L, 1L))

  # Don't fill the row level list
  expect_equal(validation_list$row_level_errors, NULL)

})


test_that("It reports problems at row level",{

  data_used = data.table::as.data.table(mtcars,
                                        keep.rownames = "Car (Name)")

  validation_list =
    validate_rules(data_used,
                   "mpg low" = mpg > min_mpg,
                   "hp high" = hp < 200,
                   env = list(min_mpg = 15),
                   keep_rl_cols = "Car (Name)")

  # It reporting all errors
  expect_equal(validation_list$summary$fails, c(6L, 7L))

  # It's selecting the correct columns
  expect_equal(names(validation_list$row_level_errors$`mpg.low`),
               c("Broken Rule", "Car (Name)", "mpg"))
  expect_equal(names(validation_list$row_level_errors$`hp.high`),
               c("Broken Rule", "Car (Name)", "hp"))

  # It's selecting the correct correct rows
  expect_equal(validation_list$row_level_errors$`mpg.low`$`Car (Name)`,
               data_used[!(mpg > 15), `Car (Name)`])
  expect_equal(validation_list$row_level_errors$`hp.high`$`Car (Name)`,
               data_used[!(hp < 200), `Car (Name)`])

})


test_that("We can select row rules to validate",{

  data_used = data.table::as.data.table(mtcars,
                                        keep.rownames = "Car (Name)")

  validation_list =
    validate_rules(data_used,
                   "mpg low" = mpg > min_mpg,
                   "hp high" = hp < 200,
                   env = list(min_mpg = 15),
                   keep_rl_cols = "Car (Name)",
                   select_rl_rules = "hp.high")

  # Select row level don't affect the summary
  expect_equal(validation_list$summary$fails, c(6L, 7L))

  # Only the defined row level rule must be in the list
  expect_equal(names(validation_list$row_level_errors), "hp.high")

  # It shows a useful message if error
  expect_error({
    validate_rules(data_used,
                   "mpg low" = mpg > min_mpg,
                   "hp high" = hp < 200,
                   env = list(min_mpg = 15),
                   keep_rl_cols = "Car (Name)",
                   select_rl_rules = "no.created.rule")
  },
  regexp = "^Please select a valid row rule")

})

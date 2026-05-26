test_that("no error", {
  skip_on_cran()
  expect_no_error(
    shinyClinicalDescriptions(directory = tempdir(),
                      open = FALSE)
  )
  expect_no_error(
    shinyDataSourceDescriptions(directory = tempdir(),
                              open = FALSE)
  )
})

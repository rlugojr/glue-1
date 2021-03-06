context("glue")

test_that("inputs are concatenated, interpolated variables recycled", {
  expect_identical(as_glue(c("testastring1", "testastring2")), glue("test", "a", "string", "{1:2}"))
})
test_that("glue errors if the expression fails", {
  expect_error(glue("{NoTfOuNd}"), "object .* not found")
})

test_that("glue errors if invalid f-string", {
  expect_error(glue("x={x"), "Expecting '}'")
})

test_that("glue works with single expressions", {
  foo <- "foo"
  expect_identical(as_glue(foo), glue("{foo}"))

  foo <- 1L
  expect_identical(as_glue(foo), glue("{foo}"))

  foo <- as.raw(1)
  expect_identical(as_glue(foo), glue("{foo}"))

  foo <- TRUE
  expect_identical(as_glue(foo), glue("{foo}"))

  foo <- as.Date("2016-01-01")
  expect_identical(as_glue(foo), glue("{foo}"))
})

test_that("glue works with repeated expressions", {
  foo <- "foo"
  expect_identical(as_glue(paste(foo, foo)), glue("{foo} {foo}"))

  foo <- 1L
  expect_identical(as_glue(paste(as.character(foo), as.character(foo))), glue("{foo} {foo}"))

  foo <- as.raw(1)
  expect_identical(as_glue(paste(as.character(foo), as.character(foo))), glue("{foo} {foo}"))

  foo <- TRUE
  expect_identical(as_glue(paste(as.character(foo), as.character(foo))), glue("{foo} {foo}"))

  foo <- as.Date("2016-01-01")
  expect_identical(as_glue(paste(as.character(foo), as.character(foo))), glue("{foo} {foo}"))
})

test_that("glue works with multiple expressions", {
  foo <- "foo"
  bar <- "bar"
  expect_identical(as_glue(paste(foo, bar)), glue("{foo} {bar}"))

  foo <- 1L
  bar <- 2L
  expect_identical(as_glue(paste(as.character(foo), as.character(bar))), glue("{foo} {bar}"))

  foo <- as.raw(1)
  bar <- as.raw(2)
  expect_identical(as_glue(paste(as.character(foo), as.character(bar))), glue("{foo} {bar}"))

  foo <- TRUE
  bar <- FALSE
  expect_identical(as_glue(paste(as.character(foo), as.character(bar))), glue("{foo} {bar}"))

  foo <- as.Date("2016-01-01")
  bar <- as.Date("2016-01-02")
  expect_identical(as_glue(paste(as.character(foo), as.character(bar))), glue("{foo} {bar}"))
})

test_that("glue with doubled braces are converted glue single braces", {
  expect_identical(as_glue("{foo}"), glue("{{foo}}"))
})

test_that("glue works with complex expressions", {
  `foo}\`` <- "foo"

  expect_identical(as_glue(`foo}\``), glue("{
      {
        '}\\'' # { and } in comments, single quotes
        \"}\\\"\" # or double quotes are ignored
        `foo}\\`` # as are { in backticks
      }
  }"))
})

test_that("glue works with large outputs", {
  # initial buffer allocates input string length + 1024, 40 * 26 = 1040
  foo <- paste(rep(letters, 40), collapse = "")

  # re-allocation on result
  expect_identical(as_glue(foo), glue("{foo}"))

  # re-allocation on input
  bar <- paste(rep(letters, 40), collapse = "")
  additional <- " some more text that requires an allocation"
  expect_identical(as_glue(paste0(bar, additional)), glue("{bar}", additional))
})

test_that("glue works with named arguments", {
  name <- "Fred"
  res <- glue('My name is {name},',
    ' my age next year is {age + 1}',
    name = "Joe",
    age = 40)

  expect_identical(as_glue("My name is Joe, my age next year is 41"), res)

  expect_identical("Fred", name)
})

test_that("glue evaluates arguments in the expected environment", {
  x <- 2
  fun <- function() {
    x <- 1
    glue("x: {x}, x+1: {y}", y = x + 1, .envir = parent.frame())
  }

  expect_identical(as_glue("x: 2, x+1: 3"), fun())
})

test_that("error if non length 1 inputs", {
  expect_error(glue(1:2, "{1:2}"), "All unnamed arguments must be length 1")
})

test_that("error if not simple recycling", {
  expect_error(glue("{1:2}{1:10}"), "Variables must be length 1 or 10")
})

test_that("recycle_columns returns if zero length input", {
  expect_identical(list(), recycle_columns(list()))
})

test_that("collapse works", {
  expect_identical("", collapse(character(0)))

  expect_identical("123", collapse(1:3))
})

test_that("glue_data evaluates in the object first, then enclosure, then parent", {
  x <- 1
  y <- 1
  z <- 1
  fun <- function(env = environment()) {
    y <- 2
    glue_data(list(x = 3), "{x} {y} {z}", .envir = env)
  }

  # The function environment
  expect_identical(as_glue("3 2 1"), fun())

  # This environment
  env <- environment()
  expect_identical(as_glue("3 1 1"), fun(env))
})

test_that("trim works", {
  expect_identical(as_glue("test"), trim("test"))
  expect_identical(as_glue("test"),
    trim(
      "test"))
  expect_identical(as_glue("test"),
    trim(
      "test
    "))
  expect_identical(as_glue("test"),
    trim("
      test
    "))
  expect_identical(as_glue("test"),
    trim(
      "test"))
  expect_identical(as_glue("test\n  test2"),
    trim("
      test
        test2
    "))
  expect_identical(as_glue("test\n  test2\n    test3"),
    trim("
      test
        test2
          test3
    "))
})

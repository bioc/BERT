test_that("batch effect adjustment with references works",{
  y <- matrix(rnorm(10*6),10,6)
  y[,1:3] <- y[,1:3] + 5
  batch <- c("A","A","A","B","B","B")
  references <- c(1,1,0,1,1,0)
  expect_silent(removeBatchEffectRefs(y, batch, references))
})

test_that("features with sufficient data among referecnes are correctly identified", {
  y <- matrix(rnorm(4*5),4,5)
  y[1,1] <- NA
  y[1:3, 2] <- NA
  y[1:2, 3] <- NA
  batches <- c(1,1,2,2)
  idx = c(TRUE, TRUE, TRUE, TRUE)
  correct <- c(FALSE, FALSE, FALSE, TRUE, TRUE)
  t <- identify_adjustableFeatures_refs(t(y), batches, idx)
  expect_true(all.equal(t, correct))
})

test_that("References can be correctly identified",{
  batch <- c("A","A","A","A","A","B","B","B","B","B")
  references <- c(1,2,1,2,0,1,2,0,1,2)
  expect_true(all.equal(identify_references(batch, references), c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE)))
  batch <- c("A","A","A","B","B","B")
  references <- c(1,2,0,1,2,0)
  expect_true(all.equal(identify_references(batch, references), c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE)))
})

test_that("Requires excactly two batches",{
  batch <- c("A","A","A","A","A")
  references <- c(1,2,1,2,0)
  testthat::expect_error(identify_references(batch, references))
  batch <- c("A","A","A","A","A", "b","b","b","b","b", "c","c","c","c","c")
  references <- c(1,2,1,2,0, 1,2,1,2,0, 1,2,1,2,0)
  testthat::expect_error(identify_references(batch, references))
})

test_that("Error when references don't have sufficient class overlap",{
  y <- matrix(rnorm(10*6),10,6)
  y[,1:3] <- y[,1:3] + 5
  batch <- c("A","A","A","B","B","B")
  references <- c(1,1,0,2,2,0)
  testthat::expect_error(identify_references(batch, references))
})
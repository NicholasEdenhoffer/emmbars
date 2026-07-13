test_that("y_mean uses displayed group means for stat_summary bar baselines", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggpubr")

  df <- data.frame(
    Cell = factor(rep(c("A", "B"), each = 2), levels = c("A", "B")),
    Area = c(0, 100, 10, 20)
  )

  contrasts <- data.frame(
    contrast = "A - B",
    p.value = 0.01
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(Cell, Area)) +
    ggplot2::stat_summary(geom = "bar", fun = mean)

  default_out <- add_emmeans_pbars(p, contrasts, y_offset = 0)
  out <- add_emmeans_pbars(p, contrasts, y_mean = TRUE, y_offset = 0)
  default_annotation_data <- default_out$layers[[length(default_out$layers)]]$data
  annotation_data <- out$layers[[length(out$layers)]]$data

  expect_equal(default_annotation_data$y.position, 100)
  expect_equal(annotation_data$y.position, 50)
})

test_that("panel y-position scope stacks all non-faceted brackets together", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggpubr")

  df <- data.frame(
    Cell = factor(rep(c("A", "B"), each = 2), levels = c("A", "B")),
    Area = c(1, 2, 10, 11),
    Treatment = rep(c("Control", "Drug"), 2)
  )

  contrasts <- data.frame(
    contrast = c("A - B", "A - B"),
    Treatment = c("Control", "Drug"),
    p.value = c(0.01, 0.02)
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(Cell, Area, fill = Treatment)) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.75))

  out <- add_emmeans_pbars(
    p,
    contrasts,
    y_offset = 0,
    step.increase = 0.1,
    y_position_scope = "panel"
  )

  annotation_data <- out$layers[[length(out$layers)]]$data

  expect_equal(annotation_data$y.position, c(11, 12))
})

test_that("context y-position scope preserves grouped y stacks", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggpubr")

  df <- data.frame(
    Cell = factor(rep(c("A", "B"), each = 2), levels = c("A", "B")),
    Area = c(1, 2, 10, 11),
    Treatment = rep(c("Control", "Drug"), 2)
  )

  contrasts <- data.frame(
    contrast = c("A - B", "A - B"),
    Treatment = c("Control", "Drug"),
    p.value = c(0.01, 0.02)
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(Cell, Area, fill = Treatment)) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.75))

  out <- add_emmeans_pbars(
    p,
    contrasts,
    y_offset = 0,
    step.increase = 0.1,
    y_position_scope = "context"
  )

  annotation_data <- out$layers[[length(out$layers)]]$data

  expect_equal(annotation_data$y.position, c(10, 11))
})

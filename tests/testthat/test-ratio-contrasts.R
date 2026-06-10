test_that("ratio contrast labels with odds.ratio columns are parsed", {
  cells <- factor(
    c("No Stromal Cells", "LX-2", "PT1-NL", "PT1-CLMet", "PT2-AppT"),
    levels = c("No Stromal Cells", "LX-2", "PT1-NL", "PT1-CLMet", "PT2-AppT")
  )

  plot_df <- expand.grid(
    Position = factor(c("Proximal", "Distal"), levels = c("Proximal", "Distal")),
    Cell = cells,
    rep = seq_len(4),
    KEEP.OUT.ATTRS = FALSE
  )
  plot_df$y <- ifelse(plot_df$Position == "Proximal", 2.5, 1.5) +
    as.numeric(plot_df$Cell) * 0.25 + plot_df$rep * 0.03

  contrasts <- data.frame(
    contrast = factor(rep("Proximal / Distal", 5)),
    Cell = cells,
    odds.ratio = c(5.4928795, 30.0562953, 25.5417608, 73.6011911, 0.8526664),
    SE = c(1.2294905, 15.2171730, 5.7565140, 14.2553605, 0.3754706),
    df = rep(Inf, 5),
    asymp.LCL = c(3.5421964, 11.1424690, 16.4213919, 50.3524804, 0.3597109),
    asymp.UCL = c(8.517801, 81.075468, 39.727543, 107.584280, 2.021179),
    null = rep(1, 5),
    z.ratio = c(7.610355, 6.721599, 14.377338, 22.194218, -0.361956),
    p.value = c(2.733432e-14, 1.797406e-11, 7.180393e-47, 3.905809e-109, 7.173849e-01)
  )

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(Position, y)) +
    ggplot2::geom_point() +
    ggplot2::facet_wrap(~ Cell)

  p2 <- add_emmeans_pbars(p, contrasts, hide.ns = FALSE, label = "p.format")
  annotation <- p2$layers[[length(p2$layers)]]$data

  expect_s3_class(p2, "ggplot")
  expect_equal(nrow(annotation), 5)
  expect_equal(as.character(annotation$group1), rep("Proximal", 5))
  expect_equal(as.character(annotation$group2), rep("Distal", 5))
  expect_equal(annotation$xmin, rep(1, 5))
  expect_equal(annotation$xmax, rep(2, 5))
  expect_true(all(is.finite(annotation$y.position)))
  expect_true("odds.ratio" %in% names(annotation))

  contrasts$contrast <- factor(rep("Proximal/Distal", 5))
  p3 <- add_emmeans_pbars(p, contrasts, hide.ns = FALSE)
  compact_annotation <- p3$layers[[length(p3$layers)]]$data

  expect_equal(as.character(compact_annotation$group1), rep("Proximal", 5))
  expect_equal(as.character(compact_annotation$group2), rep("Distal", 5))
  expect_equal(compact_annotation$xmin, rep(1, 5))
  expect_equal(compact_annotation$xmax, rep(2, 5))
})

test_that("odds-ratio asymptotic CI columns are not treated as plot context", {
  cells <- factor(
    c("No Stromal Cells", "LX-2", "PT1-NL", "PT1-CLMet", "PT2-AppT"),
    levels = c("No Stromal Cells", "LX-2", "PT1-NL", "PT1-CLMet", "PT2-AppT")
  )

  response_df <- data.frame(
    Proximity = factor(rep(c("Proximal", "Distal"), times = 5), levels = c("Proximal", "Distal")),
    Cell = factor(rep(cells, each = 2), levels = levels(cells)),
    prob = c(0.590, 0.208, 0.857, 0.167, 0.971, 0.569, 0.990, 0.575, 0.500, 0.540),
    SE = c(0.0730, 0.0401, 0.0815, 0.0719, 0.0106, 0.0776, 0.012, 0.070, 0.10, 0.10),
    df = Inf,
    asymp.LCL = c(0.4436, 0.1399, 0.6194, 0.0676, 0.9414, 0.4155, 0.950, 0.430, 0.320, 0.360),
    asymp.UCL = c(0.722, 0.297, 0.957, 0.355, 0.986, 0.711, 0.998, 0.700, 0.680, 0.700)
  )

  contrasts <- data.frame(
    contrast = factor(rep("Proximal / Distal", 5)),
    Cell = cells,
    odds.ratio = c(5.493, 30.056, 25.542, 73.601, 0.853),
    SE = c(1.230, 15.200, 5.760, 14.300, 0.375),
    df = Inf,
    asymp.LCL = c(3.54, 11.14, 16.42, 50.35, 0.36),
    asymp.UCL = c(8.52, 81.08, 39.73, 107.58, 2.02),
    null = 1,
    z.ratio = c(7.610, 6.722, 14.377, 22.194, -0.362),
    p.value = c(2.733432e-14, 1.797406e-11, 7.180393e-47, 3.905809e-109, 7.173849e-01)
  )

  p <- ggplot2::ggplot(response_df, ggplot2::aes(x = Cell, y = prob, color = Proximity)) +
    ggplot2::geom_pointrange(
      ggplot2::aes(ymin = asymp.LCL, ymax = asymp.UCL),
      position = ggplot2::position_dodge(width = 0.3)
    )

  p2 <- add_emmeans_pbars(
    p,
    contrasts,
    y_offset = 0.1,
    step.increase = 0.04,
    dodge_width = 0.3,
    tip.length = 0.01,
    y_col = "prob"
  )

  expect_equal(length(p2$layers), length(p$layers) + 1)

  annotation <- p2$layers[[length(p2$layers)]]$data
  expect_equal(nrow(annotation), 4)
  expect_equal(as.character(annotation$group1), rep("Proximal", 4))
  expect_equal(as.character(annotation$group2), rep("Distal", 4))
  expect_equal(as.character(annotation$Cell), as.character(cells[1:4]))
  expect_true(all(is.finite(annotation$y.position)))

  p3 <- add_emmeans_pbars(
    p,
    contrasts,
    y_offset = 0.1,
    step.increase = 0.04,
    dodge_width = 0.3,
    tip.length = 0.01,
    color = "Proximity",
    y_col = "prob"
  )

  expect_equal(length(p3$layers), length(p$layers) + 1)
  expect_no_error(ggplot2::ggplotGrob(p3))
})

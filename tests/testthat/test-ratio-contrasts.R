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

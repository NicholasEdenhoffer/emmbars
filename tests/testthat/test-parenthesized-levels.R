test_that("emmeans-parenthesized level names with hyphens are parsed", {
  # emmeans wraps any level name matching the `parens` option (default
  # "-|\\+|\\/|\\*") in parentheses, so a depth band like "0-50 µm" arrives as
  # "(51-100 µm) - (0-50 µm)". Splitting on " - " without tracking paren depth
  # used to cut inside the level name and leave orphan parens on both halves.
  bands <- factor(
    c("0-50 um", "51-100 um", "101-150 um"),
    levels = c("0-50 um", "51-100 um", "101-150 um")
  )

  plot_df <- expand.grid(
    Distance_bin = bands,
    Arm = factor(c("Control", "Treated"), levels = c("Control", "Treated")),
    rep = seq_len(4),
    KEEP.OUT.ATTRS = FALSE
  )
  plot_df$y <- as.numeric(plot_df$Distance_bin) + plot_df$rep * 0.05

  contrasts <- data.frame(
    contrast = c(
      "(51-100 um) - (0-50 um)", "(101-150 um) - (0-50 um)",
      "(51-100 um) - (0-50 um)", "(101-150 um) - (0-50 um)"
    ),
    Arm = factor(rep(c("Control", "Treated"), each = 2),
                 levels = c("Control", "Treated")),
    estimate = c(1.1, 2.2, 1.3, 2.4),
    p.value  = c(0.001, 0.0001, 0.02, 0.003)
  )

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(Distance_bin, y, colour = Arm)) +
    ggplot2::geom_point()

  p2 <- add_emmeans_pbars(p, contrasts, dodge_width = 0.5)
  annotation <- p2$layers[[length(p2$layers)]]$data

  expect_s3_class(p2, "ggplot")
  expect_equal(nrow(annotation), 4)
  expect_equal(
    as.character(annotation$group1),
    c("51-100 um", "101-150 um", "51-100 um", "101-150 um")
  )
  expect_equal(as.character(annotation$group2), rep("0-50 um", 4))

  # Control sits left of centre, Treated right, so the same band comparison
  # lands at different x positions in each arm.
  expect_equal(annotation$xmin, c(2, 3, 2, 3) + rep(c(-0.125, 0.125), each = 2))
  expect_equal(annotation$xmax, rep(1, 4) + rep(c(-0.125, 0.125), each = 2))
})

test_that("unparenthesized labels still split on the outer separator", {
  plot_df <- expand.grid(
    Arm = factor(c("No 5FU", "5FU"), levels = c("No 5FU", "5FU")),
    rep = seq_len(4),
    KEEP.OUT.ATTRS = FALSE
  )
  plot_df$y <- as.numeric(plot_df$Arm) + plot_df$rep * 0.05

  contrasts <- data.frame(
    contrast = "5FU - No 5FU",
    estimate = 1.2,
    p.value  = 0.004
  )

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(Arm, y)) + ggplot2::geom_point()

  annotation <- add_emmeans_pbars(p, contrasts)$layers[[2]]$data

  expect_equal(as.character(annotation$group1), "5FU")
  expect_equal(as.character(annotation$group2), "No 5FU")
  expect_equal(annotation$xmin, 2)
  expect_equal(annotation$xmax, 1)
})

# emmbars

`emmbars` provides `add_emmeans_pbars()`, a convenience function that adds
statistical significance brackets to ggplot objects using post hoc comparisons
from `emmeans::pairs()` or `emmeans::contrast()`.

Bracket positions are inferred automatically from the plot structure, with
support for facets, nested facets, dodged geoms, and fill/color aesthetics.

## Installation

```r
# Install from local directory
remotes::install_local("path/to/emmbars")

# Or with devtools
devtools::install_local("path/to/emmbars")
```

## Dependencies

```r
install.packages(c("dplyr", "tidyr", "rlang", "ggpubr", "ggplot2", "emmeans"))
```

## Quick start

```r
library(emmbars)
library(emmeans)
library(ggplot2)

emm <- emmeans(fit, ~ Cell | Spheroid) |> pairs()

p <- df |>
  ggplot(aes(Cell, Area_mm2_log10)) +
  geom_boxplot() +
  facet_wrap(~ Spheroid)

add_emmeans_pbars(p, emm)
```

## Use cases

### 1. Simple boxplot

```r
emm <- emmeans(fit, ~ Cell) |> pairs()
p   <- df |> ggplot(aes(Cell, Area)) + geom_boxplot()
add_emmeans_pbars(p, emm)
```

### 2. Faceted boxplot

```r
emm <- emmeans(fit, ~ Cell | Spheroid) |> pairs()
p   <- df |>
  ggplot(aes(Cell, Area)) +
  geom_boxplot() +
  facet_wrap(~ Spheroid)
add_emmeans_pbars(p, emm)
```

### 3. Multiple nested facets

```r
emm <- emmeans(fit, ~ Cell | Spheroid + Matrix) |> pairs()
p   <- df |>
  ggplot(aes(Cell, Area)) +
  geom_boxplot() +
  facet_nested_wrap(~ Spheroid + Matrix)
add_emmeans_pbars(p, emm)
```

### 4. Dodged fill comparison

```r
emm <- emmeans(fit, ~ Cell | Spheroid) |> pairs()
p   <- df |> ggplot(aes(Cell, Area, fill = Spheroid)) + geom_boxplot()
add_emmeans_pbars(p, emm)
```

### 5. Fill groups within x-axis levels

```r
emm <- emmeans(fit, ~ Cell | Spheroid) |> pairs()
p   <- df |> ggplot(aes(Spheroid, Area, fill = Cell)) + geom_boxplot()
add_emmeans_pbars(p, emm)
```

## Options

```r
# Significance stars (default), formatted p-values, or raw p-values
add_emmeans_pbars(p, emm, label = "stars")
add_emmeans_pbars(p, emm, label = "p.format")
add_emmeans_pbars(p, emm, label = "p.value")

# Show nonsignificant comparisons
add_emmeans_pbars(p, emm, hide.ns = FALSE)

# Adjust bracket height and spacing
add_emmeans_pbars(p, emm, y_offset = 0.10, step.increase = 0.12)

# Match a custom dodge width
p <- df |>
  ggplot(aes(Cell, Area, fill = Spheroid)) +
  geom_boxplot(position = position_dodge(width = 0.8))
add_emmeans_pbars(p, emm, dodge_width = 0.8)
```

## Key rule for emmeans

The emmeans formula should mirror the plot structure:

```r
emmeans(model, ~ compared_variable | facet_and_context_variables) |> pairs()
```

For a faceted plot `facet_wrap(~ Spheroid + Matrix)` comparing `Cell`:

```r
emmeans(fit, ~ Cell | Spheroid + Matrix) |> pairs()
```

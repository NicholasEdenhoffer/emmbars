# emmbars

`emmbars` provides `add_emmeans_pbars()`, a convenience function that adds
statistical significance brackets to ggplot objects using post hoc comparisons
from `emmeans::pairs()` or `emmeans::contrast()`.

Bracket positions are inferred automatically from the plot structure, with
support for facets, nested facets, dodged geoms, and fill/color aesthetics.

Current version: 0.2.1.

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

### 6. Bar plots of group means

```r
emm <- emmeans(fit, ~ Cell) |> pairs()
p   <- df |>
  ggplot(aes(Cell, Area)) +
  stat_summary(geom = "bar", fun = mean)
add_emmeans_pbars(p, emm, y_mean = TRUE)
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

# Enlarge the star / p-value label text (NULL uses the ggpubr default)
add_emmeans_pbars(p, emm, label_size = 6)

# Stack y positions by facet panel (default), context variables, or globally
add_emmeans_pbars(p, emm, y_position_scope = "panel")
add_emmeans_pbars(p, emm, y_position_scope = "context")
add_emmeans_pbars(p, emm, y_position_scope = "global")

# Position brackets from displayed group means rather than raw data maxima.
# Use with stat_summary(geom = "bar", fun = mean).
add_emmeans_pbars(p, emm, y_mean = TRUE)

# Match a custom dodge width
p <- df |>
  ggplot(aes(Cell, Area, fill = Spheroid)) +
  geom_boxplot(position = position_dodge(width = 0.8))
add_emmeans_pbars(p, emm, dodge_width = 0.8)
```

## Significance stars

`label = "stars"` uses a 5-tier scheme:

| p-value | Label |
|---------|-------|
| < 0.0001 | `****` |
| < 0.001 | `***` |
| < 0.01 | `**` |
| < 0.05 | `*` |
| >= 0.05 | `ns` |

Nonsignificant brackets are dropped entirely unless `hide.ns = FALSE`.

## Level names containing operator characters

emmeans wraps any factor level whose name matches its `parens` option (default
`-|\+|\/|\*`) in parentheses before building the contrast label. A depth band
like `0-50 um` therefore arrives as:

```
(51-100 um) - (0-50 um)
```

Since 0.2.1 the contrast label is split on the outer separator only, tracking
parenthesis depth, so a hyphen or slash inside a level name is no longer
mistaken for the contrast separator. The outer parentheses are then stripped so
`group1` and `group2` match the factor levels in the plot data. Unparenthesized
labels such as `5FU - No 5FU` still split on the surrounding ` - ` as before,
and no change to the emmeans call or the plot is needed.

## Key rule for emmeans

The emmeans formula should mirror the plot structure:

```r
emmeans(model, ~ compared_variable | facet_and_context_variables) |> pairs()
```

For a faceted plot `facet_wrap(~ Spheroid + Matrix)` comparing `Cell`:

```r
emmeans(fit, ~ Cell | Spheroid + Matrix) |> pairs()
```

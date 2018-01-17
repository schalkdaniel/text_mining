metrikOwn = function (x, y, method = "cosine", p = 2)
{
  if (method == "cosine") {
    return (crossprod(x, y) / (sqrt(sum(x^2)) * sqrt(sum(y^2))))
  }
  if (method == "euclidean") {
    return (sqrt(sum((x - y)^2)))
  }
  if (method == "p-norm") {
    return (sum((x - y)^p)^(1 / p))
  }
}

# x = c(1,1)
# y = c(2,2)
# 
# metrikOwn(x, y)
# 
# x = c(1,1)
# y = c(-1, 1)
# 
# metrikOwn(x, y)
# 
# x = c(1,1)
# y = c(-1, -1)
# 
# metrikOwn(x, y)


## Sample from hypercube

sampleHypercube = function (dim = 3, nsim = 100)
{
  return (matrix(runif(n = dim * nsim, min = 0, max = 1), ncol = dim))
}

dims = c(3, 5, 10, 100, 500, 1000, 5000)
run.sim = 50

ratios = matrix(NA_real_, nrow = length(dims), ncol = run.sim)

set.seed(pi)

for (i in seq_along(dims)) {
  for (j in seq_len(run.sim)) {
    
    X = sampleHypercube(dim = dims[i], nsim = 1000)
    dists = apply(X = X, MARGIN = 1, FUN = function (x) {
      metrikOwn(x, 0, method = "euclidean")
    })
    
    ratios[i, j] = (max(dists) - min(dists)) / min(dists)
  }
}

library(ggplot2)
library(ggthemes)
library(dplyr)
library(tidyr)

df.ratios = data.frame(Dimension = dims, ratios)

df.ratios = df.ratios %>%
  gather(Run, Ratios, 2:(run.sim + 1)) %>%
  mutate(Dimension = factor(Dimension))

ggplot(df.ratios, aes(Dimension, Ratios)) + 
  theme_tufte(ticks=FALSE) +
  geom_tufteboxplot(median.type = "line", whisker.type = 'line', hoffset = 0, width = 3)


# sclrp.R - Solve a Contrived Linear Regression Problem
# Updated 2021-August-31 by Michael Burkhardt <michael@monkeywalk.com>
# This code is intended for use inside an AWS Lambda function.
# The function (handler) generates a random dataset with noise,
# then fits a generalized linear model and reports the error,
# (fitted) coefficients, and AIC. There are two required parameters:
#   dimensionality : number of features
#   num-records    : number of records to generate
#   
handler <- function(...) {
  opt <- list(...)

  n_features <- opt$dimensionality
  n_records <- opt$`num-records`

  # Generate the data points within a fixed range
  X <- matrix(rnorm(n_records * n_features, 0, 1), ncol=n_features)

  # Generate the coefficients within a fixed range
  Beta <- runif(n_features, -1, 1)

  # Compute the true y values
  y_true <- X %*% Beta

  # Jitter the y values
  y <- y_true + rnorm(n_records, 0, 0.02)

  # Fit a linear model
  model <- glm.fit(X, y, intercept=FALSE)

  # Return results
  list(
    error=model$error,
    coefficients=model$coefficients,
    aic=model$aic
  )
}

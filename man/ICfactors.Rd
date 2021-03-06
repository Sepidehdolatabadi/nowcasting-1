% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ICfactors.R
\name{ICfactors}
\alias{ICfactors}
\title{Information criteria for determining the number of factors in a factors model}
\usage{
ICfactors(x, rmax = NULL, type = 2)
}
\arguments{
\item{x}{a dataset;}

\item{rmax}{a positive integer corresponding to the maximum number of factors for which the information criterion should be tested;}

\item{type}{a positive integer corresponding to the chosen information criterion (1,2,3). The default is 2.}
}
\value{
A \code{list} containing two elements:

\item{r_star}{The number of factors minimizing the information criterion;}
\item{IC}{A vector of values of the information criterion for the number of factors within the selected range.}
}
\description{
Minimizes the selected information criterion to determine the number of factors to be used in an approximate factor model.
}
\references{
Bai, J., Ng, S. (2002). Determining the Number of Factors in Approximate Factor Models. Econometrica, 70(1), 191-221. <doi:10.1111/1468-0262.00273>
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_locality_lookup.R
\name{get_locality_lookup}
\alias{get_locality_lookup}
\title{Read in most recent Geography team locality lookup file}
\usage{
get_locality_lookup(
  columns,
  aggregate = FALSE,
  matching_variable = NULL,
  new_variables = NULL
)
}
\arguments{
\item{columns}{A character vector of columns}

\item{aggregate}{Should the lookup be aggregated? (default FALSE)}

\item{matching_variable}{The level to which the lookup should be aggregated}

\item{new_variables}{The variable(s) you wish to match on to your dataset}

\item{suffix}{A string in "YYYYMMDD" format correlating to most recent geography file}
}
\value{
A tibble with the selected columns to use as a lookup
}
\description{
Read in the most recent locality-level lookup file from the Geographies team with specified columns
}
\examples{
x <- locality_lookup("20200825", c("datazone2011", "hscp_locality"))
y <- x <- get_locality_lookup("20200825", c("ca2019name", "ca2011"), aggregate = TRUE, ca2019name, ca2011)

}
\concept{Lookups}

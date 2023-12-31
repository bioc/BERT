% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/limma_ref.R
\name{identify_references}
\alias{identify_references}
\title{Identifies the references to use for this specific batch effect adjustment}
\usage{
identify_references(batch, references)
}
\arguments{
\item{batch}{vector of batch numbers. Must contain 2 unique elements}

\item{references}{vector that contains 0, if the sample is to be c-adjusted
and a class otherwise}
}
\value{
the indices of the reference samples
}
\description{
Identifies the references to use for this specific batch effect adjustment
}

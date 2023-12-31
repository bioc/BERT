% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bert.R
\name{validate_bert_input}
\alias{validate_bert_input}
\title{Verifies that the input to BERT is valid.}
\usage{
validate_bert_input(
  data,
  cores,
  combatmode,
  corereduction,
  stopParBatches,
  backend,
  method,
  qualitycontrol,
  verify,
  labelname,
  batchname,
  referencename,
  samplename,
  covariatename,
  assayname
)
}
\arguments{
\item{data}{Matrix dataframe/SummarizedExperiment in the format (samples,
features).
Additional column names are "Batch", "Cov_X" (were X may be any number),
"Label", "Sample" and "Reference". Must contain at least two features.}

\item{cores}{The number of cores to use for parallel adjustment. Increasing
this number leads to faster adjustment, especially on Linux machines. The
default is 1.}

\item{combatmode}{Integer, encoding the parameters to use for ComBat.
1 (default)    par.prior = TRUE, mean.only = FALSE
2              par.prior = TRUE, mean.only = TRUE
3              par.prior = FALSE, mean.only = FALSE
4              par.prior = FALSE, mean.only = TRUE
Will be ignored, if method!="ComBat".}

\item{corereduction}{Reducing the number of workers by at least this number}

\item{stopParBatches}{The minimum number of batches required at a hierarchy
level to proceed with parallelized adjustment. If the number of batches
is smaller, adjustment will be performed sequentially to avoid overheads.}

\item{backend}{The backend to choose for communicating the data.
Valid choices are "default" and "file". The latter will use temp files for
communicating data chunks between the processes. after adjusting all
sub-trees as far as possible with the previous number of cores.}

\item{method}{Adjustment method to use. Should either be "ComBat", "limma"
or "ref". Also allows "None" for testing purposes, which will perform no BE
adjustment}

\item{qualitycontrol}{Boolean indicating, whether ASWs should be computed
before and after batch effect adjustment. If TRUE, will compute ASW with
respect to the "Batch" and "Label" column (if existent).}

\item{verify}{Whether the input matrix/dataframe needs to be verified before
adjustment (faster if FALSE)}

\item{labelname}{A string containing the name of the column to use as class
labels. The default is "Label".}

\item{batchname}{A string containing the name of the column to use as batch
labels. The default is "Batch".}

\item{referencename}{A string containing the name of the column to use as ref.
labels. The default is "Reference".}

\item{samplename}{A string containing the name of the column to use as sample
name. The default is "Sample".}

\item{covariatename}{A vector containing the names of columns with
categorical covariables. The default is NULL, for which all columns with
the pattern "Cov" will be selected.}

\item{assayname}{User-defined string that specifies, which assay to select,
if the input data is a SummarizedExperiment. The default is NULL.}
}
\value{
None. Will instead throw an error, if input is not as intended.
}
\description{
Verifies that the input to BERT is valid.
}

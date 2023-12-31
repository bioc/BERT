% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bert.R
\name{BERT}
\alias{BERT}
\title{Adjust data using the BERT algorithm.}
\usage{
BERT(
  data,
  cores = NULL,
  combatmode = 1,
  corereduction = 4,
  stopParBatches = 2,
  backend = "default",
  method = "ComBat",
  qualitycontrol = TRUE,
  verify = TRUE,
  labelname = "Label",
  batchname = "Batch",
  referencename = "Reference",
  samplename = "Sample",
  covariatename = NULL,
  BPPARAM = NULL,
  assayname = NULL
)
}
\arguments{
\item{data}{Matrix dataframe/SummarizedExperiment in the format (samples,
features).
Additional column names are "Batch", "Cov_X" (were X may be any number),
"Label", "Sample" and "Reference". Must contain at least two features.}

\item{cores}{The number of cores to use for parallel adjustment. Increasing
this number leads to faster adjustment, especially on Linux machines. The
default is NULL, in which case the BiocParallel::bpparam() backend will be
used. If an integer is given, a backend with the corresponding number
of workers will be created and registered as default for usage.}

\item{combatmode}{Integer, encoding the parameters to use for ComBat.
1 (default)    par.prior = TRUE, mean.only = FALSE
2              par.prior = TRUE, mean.only = TRUE
3              par.prior = FALSE, mean.only = FALSE
4              par.prior = FALSE, mean.only = TRUE
Will be ignored, if method!="ComBat".}

\item{corereduction}{Reducing the number of workers by at least this number.
Only used if cores is an integer.}

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

\item{BPPARAM}{An instance of BiocParallelParam that will be used for
parallelization. The default is null, in which case the value of
cores determines the behaviour of BERT.}

\item{assayname}{User-defined string that specifies, which assay to select,
if the input data is a SummarizedExperiment. The default is NULL.}
}
\value{
A matrix/dataframe/SummarizedExperiment mirroring the shape of the
input. The data will be batch-effect adjusted by BERT.
}
\description{
This function uses the hierarchical BERT algorithm to adjust data with
batch effects. It assumes that the data is in the format
(samples, features) and that missing values are indicated by NA.
An additional column labelled "Batch" should indicate the batch. Furthermore
all columns named "Cov_1", "Cov_2", ... will be considered as covariate
for adjustment. Columns labelled "Label" and "Sample" will be ignored,
all other columns are assumed to contain data.
}
\examples{
# generate dataset with 1000 features, 5 batches, 10 samples per batch and
# two genotypes
data = generate_dataset(1000,5,10,0.1, 2)
corrected = BERT(data, cores=2)
}

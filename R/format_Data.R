#' Verify that the Reference column of the data contains only zeros and ones
#' (if it is present at all)
#' @param batch the dataframe for this batch (samples in rows,
#' samples in columns)
#' @return either TRUE (everything correct) or FALSE (something is not correct)
verify_references <- function(batch){
    if ("Reference" %in% names(batch)){
        # no missing values
        if(any(is.na(batch$Reference))){
            logging::loginfo("Found NA in Reference column")
            return(FALSE)
        }
        is_ref <- batch$Reference!=0
        if(sum(is_ref)>1){
            return(TRUE)
        }else{
            logging::loginfo("Require at least two references per batch.")
            return(FALSE)
        }
    }
    return(TRUE)
}

#' Replaces missing values (NaN) by NA, this appears to be faster
#' 
#' @param data The data as dataframe
#' @return The data with the replaced MVs
replace_missing <- function(data){
    data[vapply(data, is.nan, logical(nrow(data)))] <- NA
    data[is.null(data)] <- NA
    return(data)
}


#' Format the data as expected by BERT.
#'
#'This function is called automatically by BERT. It removes empty columns
#'and removes a (usually very small) number of numeric values, if features are
#'unadjustable for lack of data.
#'
#' @param data Matrix or dataframe in the format (samples, features). 
#' @param labelname A string containing the name of the column to use as class
#' labels. The default is "Label".
#' @param batchname A string containing the name of the column to use as batch
#' labels. The default is "Batch".
#' @param referencename A string containing the name of the column to use as ref.
#' labels. The default is "Reference".
#' @param samplename A string containing the name of the column to use as sample
#' name. The default is "Sample".
#' @param covariatename A vector containing the names of columns with
#' categorical covariables. The default is NULL, for which all columns with
#' the pattern "Cov" will be selected.
#' Additional column names are "Batch", "Cov_X" (were X may be any number),
#' "Label" and "Sample".
#' @param assayname User-defined string that specifies, which assay to select,
#' if the input data is a SummarizedExperiment. The default is NULL.
#' @return The formatted matrix.
format_DF <- function(data, labelname="Label",batchname="Batch",
                      referencename="Reference", samplename="Sample",
                      covariatename=NULL, assayname=NULL){
    logging::loginfo("Formatting Data.")
    
    if(methods::is(data, "SummarizedExperiment")){
        # Summarized Experiment
        logging::loginfo(paste(
            "Recognized SummarizedExperiment"))
       
        
        logging::loginfo("Typecasting input to dataframe.")
        # obtain raw data from assay with observations in rows and features
        # in columns
        raw_data <- data.frame(t(SummarizedExperiment::assays(data)[[assayname]]))
        # obtain batch/label/sample/reference column
        raw_data["Batch"] <- SummarizedExperiment::colData(data)[batchname][,1]
        if("Sample" %in% names(SummarizedExperiment::colData(data))){
            raw_data["Sample"] <- SummarizedExperiment::colData(
                data)[samplename][,1]
        }
        if(labelname %in% names(SummarizedExperiment::colData(data))){
            raw_data["Label"] <- SummarizedExperiment::colData(
                data)[labelname][,1]
        }
        if(referencename %in% names(SummarizedExperiment::colData(data))){
            raw_data["Reference"] <- SummarizedExperiment::colData(
                data)[referencename][,1]
        }
        # potential covariables
        cov_names <- names(
            SummarizedExperiment::colData(data))[grepl(
                "Cov" ,names( SummarizedExperiment::colData(data)  ) )]
        if(length(cov_names)>0){
            for(n in cov_names){
                raw_data[n] <- SummarizedExperiment::colData(data)[n][,1]
            }
        }
        data <-  raw_data
    }
    if(is.matrix(data)){
        logging::loginfo("Typecasting input to dataframe.")
        data <- data.frame(data)
    }
    
    logging::loginfo("Replacing NaNs with NAs.")
    data <- replace_missing(data)
    
    # rename according to user-specified column names
    if(batchname %in% names(data)){
        names(data)[names(data) == batchname] <- "Batch"
    }
    if(labelname %in% names(data)){
        names(data)[names(data) == labelname] <- "Label"
    }
    if(referencename %in% names(data)){
        names(data)[names(data) == referencename] <- "Reference"
    }
    
    if(!is.null(covariatename)){
        if(!all(vapply(covariatename, function(x){x %in% names(data)},
                       logical(1)))){
            logging::logerror(paste("Not all of the user specified column",
                                    "names could be found in the input data."))
        }
        temp <- vapply(names(data), function (x) {x %in% covariatename},
                       logical(1))
        names(data)[temp] <- vapply(names(data)[temp],
                                   function (x) {paste("Cov_", x, sep = "")},
                                   character(1))
    }
    
    # get names of potential covariables
    cov_names <- names(data)[grepl( "Cov" , names( data  ) )]
    
    if(length(cov_names)==1){
        if(!is.character(data[1, cov_names])){
            cov_names <- character(0)
        }
    }else{
        dtypes <- vapply(data[, cov_names], typeof, character(1))
        cov_names <- cov_names[dtypes=="character"]
    }
    if(length(cov_names)>0){
        stop("Covariables with non-integer values detected.")
    }
    
    logging::loginfo("Removing potential empty rows and columns")
    `%>%` <- janitor::`%>%`
    data <- data %>% janitor::remove_empty(c("rows", "cols"))
    
    # count number of missing values
    inital_mvs <- sum(is.na(data))
    
    logging::loginfo(paste("Found ", inital_mvs, " missing values."))
    
    # all unique batch levels
    unique_batches <- unique(data[["Batch"]])
    
    # select covariates
    mod <- data.frame(data [ , grepl( "Cov" , names( data  ) ) ])
    
    if(ncol(mod)!=0){
        logging::loginfo(paste(
            "BERT requires at least 2 numeric values per",
            "batch/covariate level. This may reduce the",
            "number of adjustable features considerably,",
            "depending on the quantification technique."))
    }
    
    # iterate over batches and remove numeric values, if a feature
    # (e.g. protein)
    # does not contain at least 2 numeric values
    for(b in unique_batches){
        # data from batch b
        data_batch <- data[data["Batch"] == b,]
        mod_batch <- mod[data["Batch"] == b,]
        # logical with the features that can be adjusted (that is, contain more
        # than 2 numeric values in this batch/covariate level)
        if(ncol(mod)==0){
            adjustable_batch <- get_adjustable_features(data_batch)
        }else{
            adjustable_batch <- get_adjustable_features_with_mod(
                data_batch,data.frame(mod_batch))
        }
        # set features from this batch to missing, where adjustable_batch
        # is FALSE
        data[data["Batch"] == b, !adjustable_batch] <- NA
        # require at least two references per batch
        if(!verify_references(data_batch)){
            error_str <- paste("Reference column error in batch", b)
            stop(error_str)
        }
    }
    # count missing values
    final_mvs <- sum(is.na(data))
    
    logging::loginfo(paste(
        "Introduced", final_mvs-inital_mvs,
        "missing values due to singular proteins","at batch/covariate level."))
    
    logging::loginfo("Done")
    
    return(data)
}
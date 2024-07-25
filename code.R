start_time <- Sys.time()
writeLines(paste(Sys.time(), "Started logging...:"), log_con)

tryCatch(withCallingHandlers({
    # Run Matrix eQTL analysis
    result <- Matrix_eQTL_main(snps = SNPs_sliced, gene = feature_data, cvrt = COV_sliced,
        output_file_name = output_file_name_trans, pvOutputThreshold = pvOutputThreshold,
        useModel = useModel, errorCovariance = numeric(0), output_file_name.cis = output_file_name_cis,
        pvOutputThreshold.cis = pvOutputThresholdCis, snpspos = snp_locations, genepos = feature_locations,
        cisDist = cisDist, pvalue.hist = pvalueHist, min.pv.by.genesnp = minPvByGeneSnp,
        noFDRsaveMemory = noFDRsaveMemory, verbose = TRUE)
    # Log the results
    end_time <- Sys.time()
    duration <- end_time - start_time
    message(sprintf("MatrixEQTL completed in %s seconds.", duration), file = log_con)

    result <- list(result = result, feature_data_path = feature_data_path, feature_locations_path = feature_locations_path,
        snpFilePath = snpFilePath, covFilePath = covFilePath, snpLocPath = snpLocPath)
    # Save results
    print("1")
    saveRDS(result, file = result_path)
    print("2")

    # compress lists
    gzip(output_file_name_cis, destname = paste0(output_file_name_cis, ".gz"), remove = FALSE)
    print("3")

    gzip(output_file_name_trans, destname = paste0(output_file_name_trans, ".gz"),
        remove = FALSE)
    print("4")

    return(TRUE)

}, warning = function(w) {
    writeLines(paste(Sys.time(), "Warning:", w$message), log_con)
    invokeRestart("muffleWarning")
}, error = function(e) {
    writeLines(paste(Sys.time(), "Error:", e$message), log_con)
    stop(e)
}))

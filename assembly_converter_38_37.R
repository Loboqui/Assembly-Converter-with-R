#!/usr/bin/env Rscript

# Function to convert GWAS data from GRCh38 to GRCh37
# Requires data.table package and CrossMap software installed
convert_38_to_37 <- function(input_file, output_file, chain_file, temp_dir = NULL) {
    # Load required library
    suppressPackageStartupMessages(library(data.table))

    # Create temporary directory if not provided
    if (is.null(temp_dir)) {
        temp_dir <- tempdir()
    }

    # Define temporary file paths
    bed_38_path <- file.path(temp_dir, "temp_38.bed")
    bed_37_path <- file.path(temp_dir, "temp_37.bed")

    # Read the input file
    message("Reading input file...")

    # read then as all string
    dt <- fread(input_file)
    # convert the base_pair_location to integer
    # dt[, base_pair_location := as.integer(base_pair_location)]

    # Extract columns for BED format (chromosome, start, end)
    # BED format is 0-based for start position and 1-based for end position
    message("Creating BED file...")
    bed_dt <- dt[, .(
        chromosome,
        start = as.integer(base_pair_location) - 1, # Convert to 0-based
        end = as.integer(base_pair_location) # End position (same as original position)
    )]

    # Create a unique identifier for each position
    dt[, pos_id := .I]
    bed_dt[, pos_id := .I]


    # when fwrite, column start and end are converted to character (interger, not exponential format)

    fwrite(bed_dt, bed_38_path, sep = "\t", col.names = FALSE, scipen = 999)

    # Run CrossMap to convert coordinates
    message("Running CrossMap...")
    crossmap_command <- paste("CrossMap bed", chain_file, bed_38_path, bed_37_path)
    system_result <- system(crossmap_command)

    if (system_result != 0) {
        stop("CrossMap execution failed")
    }
    # check if the output file exists
    if (!file.exists(bed_37_path)) {
        stop("CrossMap did not produce the expected output file.")
    } else {
        message("CrossMap completed successfully.")
    }

    # Read the converted BED file
    message("Reading converted coordinates...")
    bed_37 <- fread(bed_37_path, header = FALSE)
    print(bed_37[1:5])

    new <- merge(dt, bed_37, by.x = "pos_id", by.y = "V4", all.x = TRUE)
    new[, c("pos_id", "V1", "V2", "base_pair_location") := NULL]

    setnames(new, "V3", "base_pair_location")

    print(new[1:5])

    library(dplyr)
    new <- relocate(new, base_pair_location, .after = chromosome)
    # remove the pos_id column, V1, V2, V4


    # Write the output file
    message("Writing output file...")
    new[, base_pair_location := format(base_pair_location, scientific = FALSE)]
    fwrite(new, output_file, sep = "\t")

    # Clean up temporary files
    message("Cleaning up...")
    file.remove(bed_38_path, bed_37_path)

    message("Conversion completed successfully.")
    return(invisible(TRUE))
}

# Command line interface
if (!interactive()) {
    args <- commandArgs(trailingOnly = TRUE)

    if (length(args) < 1) {
        cat("Usage: Rscript convert_gwas.R <input_file> [output_file] [temp/unmap dir]\n")
        quit(status = 1)
    }

    input_file <- args[1]
    if (length(args) >= 2) {
        output_file <- args[2]
    } else {
        output_file <- paste0(tools::file_path_sans_ext(input_file), "_build37.tsv.gz")
    }
    temp_dir <- if (length(args) >= 3) args[3] else file.path(".assembly_converter_38_37", "temp")
    if (!dir.exists(temp_dir)) {
        dir.create(temp_dir, recursive = TRUE)
    }
    chain_file <- file.path(".assembly_converter_38_37", "hg38ToHg19.over.chain.gz")

    convert_38_to_37(input_file, output_file, chain_file, temp_dir)
}

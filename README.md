# Assembly-Converter-with-R

An R wrapper using CrossMap to convert between GRCh38 and GRCh37 of Homo_sapiens, particularly suitable for GWAS (such as Mendelian randomization, PRS risk scores). Only the first two columns are needed, which are chromosome and base pair location.

## Getting started

Prerequisites: The package `data.table`, `RTools`, `dplyr` should be available for R. CrossMap should be available for the shell. You could use conda via conda-forge to install them all.

Simply run:

```bash
Rscript assembly_converter_38_37.R <your_Ch38_GWAS_file.gz>
```

In `your_Ch38_GWAS_file.gz`, first two columns are chromosome and base_pair_location, the rest are free to modify.

## Example

Replace `<your_Ch38_GWAS_file.gz>` with `example.gz`.

The converter should convert from `1:221786767 (in.gz, Ch38)` to `1:221960109 (example_build37.tsv.gz, Ch37)` Check the result with [dbsnp](https://www.ncbi.nlm.nih.gov/snp/?term=1%3A221786767)!

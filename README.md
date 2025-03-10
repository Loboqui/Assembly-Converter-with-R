# Assembly-Converter-with-R

An R wrapper using CrossMap to convert between GRCh38 and GRCh37 of Homo_sapiens, particularly suitable for GWAS (such as Mendelian randomization, PRS risk scores). Only the first two columns are needed, which are chromosome and base pair location.

## Getting started

From you shell with CrossMap available, run

```bash
Rscript assembly_converter_38_37.R your_Ch38_GWAS_file.gz
```

Enjoy!

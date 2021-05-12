#!/usr/bin/sh
#I would like to make a few shortcuts for useful NCBI entrez queries:
#1. cmd line search for taxon id (w/ appropros?)
#2. download fasta, cds nucl/prot, rna based on gcf, other acc.
#3. have option to name those files based on species name
#4. have option to do this w files on disk
#5. download/link certain kinds of metadata to species and taxonomy

#test with Yersinia pestis
genus="yersinia"
species="yersinia pestis"

#QUERY: TaxID from name
esearch -db taxonomy -query $genus |
efetch -db taxonomy -format docsum |
xtract -pattern DocumentSummary -element Id

#QUERY: Genome ACCs from name. Use the latest version of the assembly if multiple are available
esearch -db assembly -query $species |
efetch -format docsum |
xtract -pattern DocumentSummary -if LatestAccession -element LatestAccession -else -element AssemblyAccession

#QUERY: get FASTA, genbank, cds_from_genomic, rna_from_genomic, cds prots from accession

#QUERY: get species name from GCF/other accession types

#QUERY: link TaxID or other species identifier to SRA entries and assoc metadata (sequencing type, submitter, expt metadata)

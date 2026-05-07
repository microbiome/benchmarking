
# Use qiime2 as base image
FROM quay.io/qiime2/qiime2:2026.4

# Install unzip and update package lists
RUN apt update && apt install -y unzip

# Download and install Mothur
RUN wget https://github.com/mothur/mothur/releases/download/v1.48.5/Mothur.linux_x86_64.zip \
    && unzip Mothur.linux_x86_64.zip \
    && mv mothur/* /opt/conda/envs/rachis-qiime2-2026.4/bin \
    && rm -rf Mothur.linux_x86_64.zip mothur

# Install R packages from the DESCRIPTION file using conda
RUN conda install -y \
    r-bench \
    r-picante \
    r-patchwork \
    bioconductor-mia=1.19.8 \
    bioconductor-philr=1.37.1 \
    bioconductor-treesummarizedexperiment=2.15.1 \
    -c conda-forge \
    -c bioconda

# Install the GitHub package (speedyseq) using remotes
# RUN R -e "remotes::install_github('mikemc/speedyseq@0057652ff7a4244ccef2b786dca58d901ec2fc62')"
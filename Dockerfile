
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
RUN conda install -y -c conda-forge -c bioconda \
    r-bench \
    r-picante \
    r-patchwork \
    bioconductor-philr=1.37.1 \
    bioconductor-treesummarizedexperiment=2.15.1

# Install devel versions of some packages from GitHub
RUN conda run -n rachis-qiime2-2026.4 bash -c \
    "R -e \"install.packages('remotes', repos = 'https://cloud.r-project.org/')\" && \
     R -e \"remotes::install_github('microbiome/mia@exporters')\" && \
     R -e \"remotes::install_github('mikemc/speedyseq@0057652ff7a4244ccef2b786dca58d901ec2fc62')\""

#!/bin/bash

# Build image
apptainer build --fakeroot --bind="$TMPDIR:/tmp" miabench.sif miabench.def

# Build container
wrap-container -w /opt/conda/envs/rachis-qiime2-2026.4/bin miabench.sif --prefix miabench_env

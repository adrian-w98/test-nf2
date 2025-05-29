#!/bin/bash

# Define which models to train (comma-separated, no spaces)
MODELS="simple_cnn,densenet,resnet"

# Define how many epochs to train for
EPOCHS=5

# Define output directory
OUTPUT_DIR="results_multimodel"

# Run the pipeline with all specified models
nextflow run main.nf \
    --model_types "$MODELS" \
    --epochs $EPOCHS \
    --outdir $OUTPUT_DIR
    
echo "Pipeline with models $MODELS completed. Results in $OUTPUT_DIR"
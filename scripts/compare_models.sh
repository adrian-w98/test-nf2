#!/bin/bash

# Run comparison of all models with 1 epoch
echo "Starting multi-model comparison..."
nextflow run main.nf \
    --model_types "simple_cnn,densenet,resnet" \
    --epochs 1 \
    --outdir results_comparison

echo "Model comparison completed. Check results_comparison for all results."
echo "Visualization available in flowchart.png"
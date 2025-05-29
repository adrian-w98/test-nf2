#!/bin/bash

# Resume the workflow from where it left off
echo "Resuming multi-model comparison..."
nextflow run main.nf \
    --model_types "simple_cnn,densenet,resnet" \
    --epochs 1 \
    --outdir results_comparison \
    -resume

echo "Model comparison completed. Check results_comparison for all results."
echo "Visualization available in flowchart.png"
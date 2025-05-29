process COMPARE_MODELS {
    publishDir "${params.outdir}/comparison", mode: 'copy'
    
    input:
    path metrics_files
    
    output:
    path 'model_comparison.json'
    path 'model_comparison.txt'
    path 'model_comparison.png'
    
    script:
    """
    python ${baseDir}/bin/compare_models.py \
        --metrics_files ${metrics_files} \
        --output_dir ./
    """
}
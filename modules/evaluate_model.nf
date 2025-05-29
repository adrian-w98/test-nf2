process EVALUATE_MODEL {
    publishDir "${params.outdir}/evaluation/${model_type}", mode: 'copy'
    
    input:
    tuple val(model_type), path(model)
    path test_data
    val model_type
    val device
    
    output:
    tuple val(model_type), path('evaluation_metrics.json'), path('confusion_matrix.png'), path('roc_curve.png')
    
    script:
    """
    python ${baseDir}/bin/evaluate.py \
        --model ${model} \
        --test_data ${test_data} \
        --model_type ${model_type} \
        --device ${device} \
        --output_dir ./
    """
}
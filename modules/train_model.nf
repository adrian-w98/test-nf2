process TRAIN_MODEL {
    publishDir "${params.outdir}/model/${model_type}", mode: 'copy'
    
    input:
    path train_data
    path val_data
    each model_type
    val epochs
    val batch_size
    val learning_rate
    val device
    
    output:
    tuple val(model_type), path('model.pt'), emit: model
    tuple val(model_type), path("${model_type}_metrics.json"), emit: metrics
    val model_type, emit: model_type
    
    script:
    """
    python ${baseDir}/bin/train.py \
        --train_data ${train_data} \
        --val_data ${val_data} \
        --model_type ${model_type} \
        --epochs ${epochs} \
        --batch_size ${batch_size} \
        --learning_rate ${learning_rate} \
        --device ${device} \
        --output_dir ./
        
    # Rename the output file to include model type
    mv training_metrics.json ${model_type}_metrics.json
    """
}
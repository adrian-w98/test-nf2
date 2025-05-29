#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Log info
log.info """\
         M E D N I S T - C L A S S I F I C A T I O N    
         ===================================
         Dataset       : ${params.data_dir}
         Output dir    : ${params.outdir}
         Model types   : ${params.model_types}
         Epochs        : ${params.epochs}
         Batch size    : ${params.batch_size}
         Learning rate : ${params.learning_rate}
         Device        : ${params.device}
         """
         .stripIndent()

// Import modules
include { PREPARE_DATA } from './modules/prepare_data'
include { TRAIN_MODEL } from './modules/train_model'
include { EVALUATE_MODEL } from './modules/evaluate_model'
include { COMPARE_MODELS } from './modules/compare_models'

// Main workflow
workflow {
    // Prepare data - only done once
    PREPARE_DATA( 
        Channel.value(params.data_dir)
    )
    
    // Process each model type in parallel
    // Convert comma-separated string to a channel of individual model types
    Channel
        .fromList(params.model_types.tokenize(','))
        .set { model_types_ch }
    
    // Train models - each model type will be processed in parallel
    TRAIN_MODEL(
        PREPARE_DATA.out.train_data,
        PREPARE_DATA.out.val_data,
        model_types_ch,
        Channel.value(params.epochs),
        Channel.value(params.batch_size),
        Channel.value(params.learning_rate),
        Channel.value(params.device)
    )
    
    // Evaluate models
    EVALUATE_MODEL(
        TRAIN_MODEL.out.model,
        PREPARE_DATA.out.test_data,
        TRAIN_MODEL.out.model_type,
        Channel.value(params.device)
    )
    
    // Collect all metrics for comparison
    TRAIN_MODEL.out.metrics
        .map { model_type, metrics_file -> metrics_file }
        .collect()
        .set { all_metrics_ch }
    
    // Compare models to find the best one
    COMPARE_MODELS(
        all_metrics_ch
    )
}

// Module definitions
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
    
    // Print comparison results location
    log.info "Model comparison results available at: ${params.outdir}/comparison/"
    log.info "To see which model performed best, check: ${params.outdir}/comparison/model_comparison.txt"
}
#!/usr/bin/env python

import os
import json
import argparse
import glob
import pandas as pd
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser(description='Compare model performance metrics')
    parser.add_argument('--metrics_files', nargs='+', required=True, help='List of metrics JSON files')
    parser.add_argument('--output_dir', required=True, help='Output directory')
    args = parser.parse_args()
    
    # Process metrics files
    model_metrics = []
    
    for metrics_file in args.metrics_files:
        # Extract model name from filename (format: model_type_metrics.json)
        filename = os.path.basename(metrics_file)
        model_name = filename.split('_metrics.json')[0]
        
        # Fallback to directory name if needed
        if not model_name:
            model_name = os.path.basename(os.path.dirname(metrics_file))
        
        with open(metrics_file, 'r') as f:
            metrics = json.load(f)
        
        # Extract key metrics
        best_val_acc = metrics.get('best_val_acc', 0)
        best_epoch = metrics.get('best_epoch', 0)
        total_time = metrics.get('total_time', 0)
        epochs = metrics.get('epochs', 0)
        
        model_metrics.append({
            'model': model_name,
            'best_val_acc': best_val_acc,
            'best_epoch': best_epoch,
            'total_time': total_time,
            'epochs': epochs,
            'time_per_epoch': total_time / epochs if epochs > 0 else 0
        })
    
    # Convert to DataFrame for easier analysis
    df = pd.DataFrame(model_metrics)
    
    # Sort by best validation accuracy
    df_sorted = df.sort_values('best_val_acc', ascending=False)
    
    # Get the best model
    best_model = df_sorted.iloc[0]
    
    # Create summary report
    report = {
        'models_compared': df.to_dict(orient='records'),
        'best_model': best_model.to_dict(),
        'performance_ranking': df_sorted[['model', 'best_val_acc']].to_dict(orient='records')
    }
    
    # Save JSON report
    with open(os.path.join(args.output_dir, 'model_comparison.json'), 'w') as f:
        json.dump(report, f, indent=4)
    
    # Create a text summary
    with open(os.path.join(args.output_dir, 'model_comparison.txt'), 'w') as f:
        f.write("MODEL COMPARISON SUMMARY\n")
        f.write("=======================\n\n")
        f.write(f"Number of models compared: {len(df)}\n")
        f.write(f"Number of epochs: {best_model['epochs']}\n\n")
        
        f.write("PERFORMANCE RANKING (by validation accuracy):\n")
        for i, (_, row) in enumerate(df_sorted.iterrows()):
            f.write(f"{i+1}. {row['model']} - {row['best_val_acc']:.2f}% (epoch {row['best_epoch']})\n")
        
        f.write("\nBEST MODEL DETAILS:\n")
        f.write(f"Model: {best_model['model']}\n")
        f.write(f"Best validation accuracy: {best_model['best_val_acc']:.2f}%\n")
        f.write(f"Best epoch: {best_model['best_epoch']}\n")
        f.write(f"Training time: {best_model['total_time']:.2f} seconds\n")
        f.write(f"Time per epoch: {best_model['time_per_epoch']:.2f} seconds\n")
    
    # Create a bar chart showing model performance
    plt.figure(figsize=(10, 6))
    plt.bar(df_sorted['model'], df_sorted['best_val_acc'], color='skyblue')
    plt.title('Model Performance Comparison')
    plt.xlabel('Model')
    plt.ylabel('Best Validation Accuracy (%)')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(os.path.join(args.output_dir, 'model_comparison.png'))
    
    print(f"Model comparison complete. Best model: {best_model['model']} with {best_model['best_val_acc']:.2f}% validation accuracy")

if __name__ == "__main__":
    main()
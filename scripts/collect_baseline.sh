#!/bin/bash

SUFFIX=$1

RESEARCH_DIR="$HOME/5g-research"
DATA_DIR="$RESEARCH_DIR/data/baseline"

OUTPUT_FILE="$DATA_DIR/raw_${SUFFIX}.log"
mkdir -p "$DATA_DIR"

# Clear the file if it exists
>$OUTPUT_FILE

PODS=$(kubectl get pods -n open5gs -o name | cut -d'/' -f2)

for POD in $PODS; do
    kubectl logs -n open5gs $POD --tail=1000 >> $OUTPUT_FILE
done

echo "Collection complete: $(du -sh $OUTPUT_FILE)"

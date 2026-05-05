#!/bin/bash

SUFFIX=$1

OUTPUT_FILE="data/baseline/raw_${SUFFIX}.log"

# Clear the file if it exists
> $OUTPUT_FILE

PODS=$(kubectl get pods -n open5gs -o name | cut -d'/' -f2)

for POD in $PODS; do
    kubectl logs -n open5gs $POD --tail=1000 >> $OUTPUT_FILE
done

echo "Collection complete: $(du -sh $OUTPUT_FILE)"
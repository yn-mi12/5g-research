#!/bin/bash

NUM_UE=$1

echo "--- Starting Experiment with $NUM_UE UEs ---"

for i in $(seq 1 $NUM_UE); do

    POD_NAME=$(kubectl get pods -n open5gs | grep "ue$i-" | awk '{print $1}')
    
    if [ ! -z "$POD_NAME" ]; then
        kubectl exec -i $POD_NAME -n open5gs -- ping -I uesimtun0 -c 200 -i 0.2 8.8.8.8 > /dev/null &
    else
        echo "Warning: Pod for ue$i not found."
    fi
done

echo "Traffic generation complete."
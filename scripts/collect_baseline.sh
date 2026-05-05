#!/bin/bash

START_TIME=$(date -u -d '5 minutes ago' +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p data/baseline

# Clear the previous file
> data/baseline/baseline_raw.log

for pod in $(kubectl get pods -n open5gs -o name); do
    kubectl logs $pod -n open5gs --since-time=$START_TIME >> data/baseline/baseline_raw.log 2>/dev/null
done

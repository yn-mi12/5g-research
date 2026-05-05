#!/bin/bash

# Get UE pod name
UE_POD=$(kubectl get pods -n open5gs | grep ueransim-ue1 | awk '{print $1}')

kubectl exec -it $UE_POD -n open5gs -- bash -c \
"for i in {1..100}; do ping -I uesimtun0 -c 1 -i 0.2 8.8.8.8; done"

echo "Traffic generation complete."
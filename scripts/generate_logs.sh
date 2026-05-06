#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./generate_logs.sh <number_of_ues>"
    echo "Example: ./generate_logs.sh 100"
    exit 1
fi

RESEARCH_DIR="$HOME/5g-research"
BASE_DIR="$RESEARCH_DIR/open5gs-k8s"
SCRIPT_DIR="$RESEARCH_DIR/scripts"
DATA_DIR="$RESEARCH_DIR/data/baseline"

TOTAL_UES=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_TAG="${TOTAL_UES}ue_${TIMESTAMP}"

mkdir -p data/baseline

echo "[1/3] Configuring Environment..."
cd "$BASE_DIR"
TOTAL_AUTO_SUBS=$TOTAL_UES ./setup-multi-ue.sh

# Refresh ConfigMaps
kubectl delete configmap ue1-configmap ue2-configmap -n open5gs --ignore-not-found
kubectl create configmap ue1-configmap -n open5gs --from-file="./ueransim/ueransim-ue/ue1/"
kubectl create configmap ue2-configmap -n open5gs --from-file="./ueransim/ueransim-ue/ue2/"

# Restart Deployments
kubectl rollout restart deployment ueransim-ue1 -n open5gs
kubectl rollout restart deployment ueransim-ue2 -n open5gs

echo "Waiting for pods..."
kubectl wait --for=condition=available deployment/ueransim-ue1 -n open5gs --timeout=90s
kubectl wait --for=condition=available deployment/ueransim-ue2 -n open5gs --timeout=90s

echo "Waiting 15 seconds for UEs to register and create tunnels..."
sleep 15

# Verify tunnel exists before pinging
kubectl exec -n open5gs deployment/ueransim-ue1 -- ip addr show uesimtun0 || echo "Wait... uesimtun0 not ready yet."

echo "[2/3] Generating Traffic..."
cd "$SCRIPT_DIR"
chmod +x ./run_variable_workload.sh
./run_variable_workload.sh $TOTAL_UES

echo "Traffic is running. Collecting data for 30 seconds..."
sleep 30

echo "[3/3] Saving Logs to $DATA_DIR/raw_${LOG_TAG}.log"
chmod +x ./collect_baseline.sh
./collect_baseline.sh $LOG_TAG
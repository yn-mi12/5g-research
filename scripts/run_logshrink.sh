#!/bin/bash

set -e
UE_COUNT=$1
if [ -z "$UE_COUNT" ]; then
    echo "Usage: ./rq1_pipeline.sh <number_of_ues>"
    exit 1
fi

RESEARCH_DIR="$HOME/5g-research"
SCRIPT_DIR="$RESEARCH_DIR/scripts"
DATA_DIR="$RESEARCH_DIR/data"

SUFFIX="${UE_COUNT}ue"
RAW_LOG="$DATA_DIR/baseline/raw_${SUFFIX}.log"
CLEAN_DIR="$DATA_DIR/cleaned"
OUTPUT_DIR="$DATA_DIR/results_logshrink/${SUFFIX}"

# Ensure directories exist
mkdir -p "$DATA_DIR/baseline" "$CLEAN_DIR" "$OUTPUT_DIR"

echo "--------------------------------"
echo "[1/3] Generating traffc and collecting logs"
echo "--------------------------------"
cd "$SCRIPT_DIR"
./generate_logs.sh $UE_COUNT

LATEST_LOG=$(ls -t $DATA_DIR/baseline/raw_${UE_COUNT}ue_*.log | head -n 1)
mv "$LATEST_LOG" "$RAW_LOG"

echo "Logs collected: $(du -sh $RAW_LOG)"

echo "--------------------------------"
echo "[2/3] Cleaning and splitting Logs"
echo "--------------------------------"
DATASET_NAME="5G_${SUFFIX}"
PREP_DIR="$DATA_DIR/cleaned/${DATASET_NAME}"
mkdir -p "$PREP_DIR"

LOG_FILE_PATH="$PREP_DIR/${DATASET_NAME}.log"

sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" "$RAW_LOG" > "$LOG_FILE_PATH"

echo "Preparation complete: $LOG_FILE_PATH"

echo "--------------------------------"
echo "[3/3] Applying LogShrink"
echo "--------------------------------"
export PYTHONPATH=$HOME/5g-research/LogShrink

cd "$HOME/5g-research/LogShrink/python_compression"

python3 run.py \
    -I "$DATA_DIR/cleaned/" \
    -ds "$DATASET_NAME" \
    -E E -C -K lzma \
    -outdir "$OUTPUT_DIR"

echo "--------------------------------"
echo "Calculating size reduction"
echo "--------------------------------"
ORIGINAL_SIZE_BYTES=$(stat -c%s "$RAW_LOG")
REDUCED_SIZE_BYTES=$(du -sb "$OUTPUT_DIR" | cut -f1)

SAVINGS=$(echo "scale=2; (1 - $REDUCED_SIZE_BYTES / $ORIGINAL_SIZE_BYTES) * 100" | bc)

echo "Baseline Raw Size: $(numfmt --to=iec $ORIGINAL_SIZE_BYTES)"
echo "Reduced Size:      $(numfmt --to=iec $REDUCED_SIZE_BYTES)"
echo "Volume Reduction:  $SAVINGS %"
echo "--------------------------------"
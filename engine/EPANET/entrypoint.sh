#!/bin/bash

# Simple EPANET entrypoint with basic error handling and logging
# Usage: docker run <image> input.inp output.rpt [output.out]
# DEBUG environment variable: set to "1" or "true" to enable detailed logging

set -euo pipefail

# Configuration
DEBUG="${DEBUG:-0}"
LOG_FILE="${LOG_FILE:-/tmp/epanet.log}"

# Logging function (respects DEBUG flag)
log() {
    if [ "$DEBUG" = "1" ] || [ "$DEBUG" = "true" ]; then
        local level="$1"
        shift
        local message="$@"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
    fi
}

# Error handler (always logs errors)
error_exit() {
    local level="ERROR"
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
    exit 1
}

# Trap errors
trap 'error_exit "Simulation failed with exit code $?"' ERR

# Validate arguments
if [ $# -lt 2 ]; then
    echo "EPANET Container - Simple Runner"
    echo ""
    echo "Usage: docker run <image> <input.inp> <output.rpt> [output.out]"
    echo ""
    echo "Arguments:"
    echo "  input.inp     Input file (local path)"
    echo "  output.rpt    Report file output path"
    echo "  output.out    Optional binary output file"
    echo ""
    echo "Environment:"
    echo "  DEBUG         Set to 1 or true to enable detailed logging"
    echo ""
    echo "Examples:"
    echo "  docker run -v \$(pwd):/workspace image example.inp example.rpt"
    echo "  docker run -v \$(pwd):/workspace image example.inp example.rpt example.out"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_RPT="$2"
OUTPUT_OUT="${3:-}"

log "INFO" "EPANET Container Runner"
log "INFO" "Input: $INPUT_FILE"
log "INFO" "Output Report: $OUTPUT_RPT"
[ -n "$OUTPUT_OUT" ] && log "INFO" "Output Binary: $OUTPUT_OUT"

# Validate input file exists
if [ ! -f "$INPUT_FILE" ]; then
    error_exit "Input file not found: $INPUT_FILE"
fi

log "INFO" "Running EPANET simulation..."

# Run EPANET
if [ -n "$OUTPUT_OUT" ]; then
    epanet "$INPUT_FILE" "$OUTPUT_RPT" "$OUTPUT_OUT" 2>&1 | tee -a "$LOG_FILE" || true
else
    epanet "$INPUT_FILE" "$OUTPUT_RPT" 2>&1 | tee -a "$LOG_FILE" || true
fi

# Verify report file was created
if [ ! -f "$OUTPUT_RPT" ]; then
    error_exit "Report file was not created: $OUTPUT_RPT"
fi

log "INFO" "Checking for errors in report file..."

# Check for ERROR keyword in report file (EPANET doesn't always exit with error code)
if grep -q "ERROR" "$OUTPUT_RPT"; then
    error_context=$(grep "ERROR" "$OUTPUT_RPT" | head -5)
    error_exit "EPANET simulation encountered errors:\n$error_context"
fi

# Verify output binary if specified
if [ -n "$OUTPUT_OUT" ] && [ ! -f "$OUTPUT_OUT" ]; then
    error_exit "Output binary file was not created: $OUTPUT_OUT"
fi

log "INFO" "Simulation completed successfully"
log "INFO" "Output files:"
ls -lh "$OUTPUT_RPT" 2>&1 | tee -a "$LOG_FILE"
[ -n "$OUTPUT_OUT" ] && ls -lh "$OUTPUT_OUT" 2>&1 | tee -a "$LOG_FILE"

exit 0

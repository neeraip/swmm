#!/bin/bash

# Simple SWMM entrypoint with basic error handling and logging
# Usage: docker run <image> input.inp output.rpt [output.out]
# DEBUG environment variable: set to "1" or "true" to enable detailed logging

set -euo pipefail

# Configuration
DEBUG="${DEBUG:-0}"
LOG_FILE="${LOG_FILE:-/tmp/swmm.log}"

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
    echo "SWMM Container - Simple Runner"
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
    echo "  docker run -v /data:/workspace myswmm model.inp report.rpt"
    echo "  docker run -v /data:/workspace myswmm model.inp report.rpt model.out"
    exit 1
fi

INPUT_FILE="$1"
REPORT_FILE="$2"
OUTPUT_FILE="${3:-}"

log "INFO" "Starting SWMM simulation"
log "INFO" "Input: $INPUT_FILE"
log "INFO" "Report: $REPORT_FILE"
[ -n "$OUTPUT_FILE" ] && log "INFO" "Output: $OUTPUT_FILE"

# Verify input file exists
if [ ! -f "$INPUT_FILE" ]; then
    error_exit "Input file not found: $INPUT_FILE"
fi

log "INFO" "Input file verified"

# Run SWMM
if [ -n "$OUTPUT_FILE" ]; then
    log "INFO" "Running: runswmm $INPUT_FILE $REPORT_FILE $OUTPUT_FILE"
    runswmm "$INPUT_FILE" "$REPORT_FILE" "$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"
else
    log "INFO" "Running: runswmm $INPUT_FILE $REPORT_FILE"
    runswmm "$INPUT_FILE" "$REPORT_FILE" 2>&1 | tee -a "$LOG_FILE"
fi

# Verify output files were created
if [ ! -f "$REPORT_FILE" ]; then
    error_exit "Report file was not created: $REPORT_FILE"
fi

# Check report file for errors (SWMM doesn't exit with error code on simulation failure)
if grep -q "ERROR" "$REPORT_FILE"; then
    error_exit "Simulation completed but report contains errors (check $REPORT_FILE)"
fi

log "INFO" "Report file created successfully: $REPORT_FILE"
[ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ] && log "INFO" "Output file created successfully: $OUTPUT_FILE"

log "INFO" "SWMM simulation completed successfully"
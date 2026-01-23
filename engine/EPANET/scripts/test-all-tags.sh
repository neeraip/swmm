#!/bin/bash

# Test all EPANET versions

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_config.sh"

# Check for test data
DATA_DIR="$(dirname "$SCRIPT_DIR")/data"
if [ ! -d "$DATA_DIR" ]; then
    mkdir -p "$DATA_DIR"
fi

# Track failed tests
failed_tests=()
failed_errors=()

echo "Testing all ${IMAGE_NAME} versions..."
echo ""

# Verify images exist locally
echo "Checking for local images..."
missing_images=()
for version in "${VERSIONS[@]}"; do
    if ! docker image inspect "${IMAGE_NAME}:${version}" > /dev/null 2>&1; then
        missing_images+=("${version}")
    fi
done

if [ ${#missing_images[@]} -gt 0 ]; then
    echo "❌ Error: Missing local Docker images:"
    for version in "${missing_images[@]}"; do
        echo "  - ${IMAGE_NAME}:${version}"
    done
    echo ""
    echo "Run the build script first:"
    echo "  ./build-all-tags.sh"
    exit 1
fi
echo "✓ All images found locally"
echo ""

# Test each version
for version in "${VERSIONS[@]}"; do
    echo -n "Testing ${IMAGE_NAME}:${version}... "
    
    OUTPUT_RPT="$DATA_DIR/example-${version}.rpt"
    OUTPUT_OUT="$DATA_DIR/example-${version}.out"
    
    if docker run --rm \
        -v "$DATA_DIR":/workspace \
        "${IMAGE_NAME}:${version}" \
        example.inp "example-${version}.rpt" "example-${version}.out" \
        > /dev/null 2>&1; then
        
        if [ -f "$OUTPUT_RPT" ]; then
            echo "✓"
        else
            echo "✗"
            failed_tests+=("$version")
            failed_errors+=("Report file not created")
        fi
    else
        echo "✗"
        failed_tests+=("$version")
        error_output=$(docker run --rm \
            -v "$DATA_DIR":/workspace \
            "${IMAGE_NAME}:${version}" \
            example.inp "example-${version}.rpt" "example-${version}.out" 2>&1 || true)
        error_context=$(echo "$error_output" | tail -5)
        failed_errors+=("$error_context")
    fi
done

echo ""
echo "Test summary:"
echo "  Total: ${#VERSIONS[@]}"
echo "  Success: $((${#VERSIONS[@]} - ${#failed_tests[@]}))"
echo "  Failed: ${#failed_tests[@]}"
echo ""
echo "Output files:"
ls -lh "$DATA_DIR"/example-*.rpt "$DATA_DIR"/example-*.out 2>/dev/null | awk -v dir="$DATA_DIR/" '{gsub(dir, "", $9); print "  " $9, "(" $5 ")"}'

if [ ${#failed_tests[@]} -gt 0 ]; then
    echo ""
    echo "Failed tests:"
    for i in "${!failed_tests[@]}"; do
        echo "  ${failed_tests[$i]}"
        echo "    ${failed_errors[$i]}" | head -1
    done
    exit 1
fi

exit 0

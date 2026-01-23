#!/bin/bash

# Test SWMM Docker images for all versions

set -o pipefail

# Source tags configuration
source "$(dirname "$0")/_config.sh"

PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
DATA_DIR="$(dirname "$0")/../data"

# Track failed tests
failed_tests=()
failed_errors=()

echo "Testing SWMM Docker images for all versions..."
echo "Data directory: $DATA_DIR"
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

for version in "${VERSIONS[@]}"; do
    image_name="${IMAGE_NAME}:${version}"
    report_file="example-${version}.rpt"
    output_file="example-${version}.out"
    
    echo -n "Testing $image_name... "
    
    # Run simulation and capture error output
    error_output=$(docker run --rm \
        -v "$DATA_DIR:/workspace" \
        -e DEBUG=0 \
        "$image_name" \
        example.inp \
        "$report_file" \
        "$output_file" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✓"
    else
        echo "✗"
        failed_tests+=("$version")
        # Capture the last 5 lines of error output
        error_context=$(echo "$error_output" | tail -5)
        failed_errors+=("$error_context")
    fi
done

# Print summary
echo "=========================================="
echo "Test Summary:"
echo "  Successful: $((${#VERSIONS[@]} - ${#failed_tests[@]}))/${#VERSIONS[@]}"
echo "  Failed: ${#failed_tests[@]}/${#VERSIONS[@]}"
echo ""
if [ ${#failed_tests[@]} -gt 0 ]; then
    echo "Failed tests:"
    for i in "${!failed_tests[@]}"; do
        version="${failed_tests[$i]}"
        error="${failed_errors[$i]}"
        echo ""
        echo "  ✗ Version $version:"
        echo "$error" | sed 's/^/    /'
    done
fi
echo ""
echo "Output files:"
ls -lh "$DATA_DIR"/example-*.rpt "$DATA_DIR"/example-*.out 2>/dev/null | awk -v dir="$DATA_DIR/" '{gsub(dir, "", $9); print "  " $9, "(" $5 ")"}'
echo ""
[ ${#failed_tests[@]} -eq 0 ] && exit 0 || exit 1

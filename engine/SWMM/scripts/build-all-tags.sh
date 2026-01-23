#!/bin/bash

# Build SWMM Docker images for multiple versions

set -uo pipefail

# Source tags configuration
source "$(dirname "$0")/_config.sh"

PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

# Track failed builds
failed_builds=()
failed_errors=()

echo "Building SWMM Docker images for multiple versions..."
echo "Project root: $PROJECT_ROOT"
echo ""

for version in "${VERSIONS[@]}"; do
    # Add 'v' prefix for GitHub tag
    github_tag="v${version}"
    image_name="${IMAGE_NAME}:${version}"
    
    echo -n "Building $image_name... "
    error_output=$(docker build \
        -f "$PROJECT_ROOT/engine/SWMM/Dockerfile" \
        --build-arg TAG="$github_tag" \
        -t "$image_name" \
        --load \
        "$PROJECT_ROOT" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✓"
        
        # Tag as latest if it's the last version
        if [ "$version" = "${VERSIONS[${#VERSIONS[@]} - 1]}" ]; then
            docker tag "$image_name" "${IMAGE_NAME}:latest" 2>/dev/null
        fi
    else
        echo "✗"
        failed_builds+=("$version")
        # Capture the last 15 lines of error output for better context
        error_context=$(echo "$error_output" | tail -15)
        failed_errors+=("$error_context")
    fi
done

# Print summary
echo "=========================================="
if [ ${#failed_builds[@]} -eq 0 ]; then
    echo "All images built successfully!"
    docker images | grep "${IMAGE_NAME}" || echo "No images found"
else
    echo "Build Summary:"
    echo "  Successful: $((${#VERSIONS[@]} - ${#failed_builds[@]}))/${#VERSIONS[@]}"
    echo "  Failed: ${#failed_builds[@]}/${#VERSIONS[@]}"
    echo ""
    echo "Failed builds:"
    for i in "${!failed_builds[@]}"; do
        version="${failed_builds[$i]}"
        error="${failed_errors[$i]}"
        echo ""
        echo "  ✗ Version $version:"
        echo "$error" | sed 's/^/    /'
    done
    exit 1
fi

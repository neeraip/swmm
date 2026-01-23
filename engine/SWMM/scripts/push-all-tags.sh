#!/bin/bash

# Push all SWMM versions to Docker Hub with multi-arch support

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_config.sh"

# Track failed pushes
failed_pushes=()
failed_errors=()

echo "Pushing all ${IMAGE_NAME} versions to ${REGISTRY}..."
echo ""

# Push each version
for version in "${VERSIONS[@]}"; do
    echo -n "Pushing ${REGISTRY}:${version}... "
    
    if docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg TAG="v${version}" \
        -t "${REGISTRY}:${version}" \
        --sbom=true \
        --provenance=true \
        --push \
        -f "$(dirname "$SCRIPT_DIR")/Dockerfile" \
        "$(dirname "$SCRIPT_DIR")/../.." \
        > /dev/null 2>&1; then
        echo "✓"
    else
        echo "✗"
        failed_pushes+=("$version")
        error_output=$(docker buildx build \
            --platform linux/amd64,linux/arm64 \
            --build-arg TAG="v${version}" \
            -t "${REGISTRY}:${version}" \
            --sbom=true \
            --provenance=true \
            --push \
            -f "$(dirname "$SCRIPT_DIR")/Dockerfile" \
            "$(dirname "$SCRIPT_DIR")/../.." 2>&1 || true)
        error_context=$(echo "$error_output" | tail -15)
        failed_errors+=("$error_context")
    fi
done

# Push latest tag (rebuild with :latest tag)
if [ ${#VERSIONS[@]} -gt 0 ]; then
    last_version="${VERSIONS[${#VERSIONS[@]} - 1]}"
    echo -n "Pushing ${REGISTRY}:latest... "
    
    if docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg TAG="v${last_version}" \
        -t "${REGISTRY}:latest" \
        --sbom=true \
        --provenance=true \
        --push \
        -f "$(dirname "$SCRIPT_DIR")/Dockerfile" \
        "$(dirname "$SCRIPT_DIR")/../.." \
        > /dev/null 2>&1; then
        echo "✓"
    else
        echo "✗"
        failed_pushes+=("latest")
        error_output=$(docker buildx build \
            --platform linux/amd64,linux/arm64 \
            --build-arg TAG="v${last_version}" \
            -t "${REGISTRY}:latest" \
            --sbom=true \
            --provenance=true \
            --push \
            -f "$(dirname "$SCRIPT_DIR")/Dockerfile" \
            "$(dirname "$SCRIPT_DIR")/../.." 2>&1 || true)
        error_context=$(echo "$error_output" | tail -15)
        failed_errors+=("$error_context")
    fi
fi

echo ""
echo "Push summary:"
echo "  Total: $((${#VERSIONS[@]} + 1))"
echo "  Success: $((${#VERSIONS[@]} + 1 - ${#failed_pushes[@]}))"
echo "  Failed: ${#failed_pushes[@]}"

if [ ${#failed_pushes[@]} -gt 0 ]; then
    echo ""
    echo "Failed pushes:"
    for i in "${!failed_pushes[@]}"; do
        echo "  ${failed_pushes[$i]}"
        echo "    ${failed_errors[$i]}" | head -1
    done
    exit 1
fi

exit 0

#!/bin/bash

# Build all HEC-RAS versions locally

set -euo pipefail

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_config.sh"

# Track failed builds
failed_builds=()
failed_errors=()

echo "Building all ${IMAGE_NAME} versions..."
echo ""

# Build each version
for version in "${VERSIONS[@]}"; do
    echo -n "Building ${IMAGE_NAME}:${version}... "

    build_log="$(mktemp)"

    if docker build \
        --platform linux/amd64 \
        --progress=plain \
        --build-arg HEC_RAS_VERSION="${version}" \
        -t "${IMAGE_NAME}:${version}" \
        -f "$(dirname "$SCRIPT_DIR")/Dockerfile" \
        --load \
        "$(dirname "$SCRIPT_DIR")" 2>&1 | tee "$build_log"; then
        echo "✓"
    else
        echo "✗"
        failed_builds+=("$version")
        error_context=$(tail -15 "$build_log")
        failed_errors+=("$error_context")
    fi

    rm -f "$build_log"
done

# Tag last version as latest
if [ ${#VERSIONS[@]} -gt 0 ]; then
    last_version="${VERSIONS[${#VERSIONS[@]} - 1]}"
    docker tag "${IMAGE_NAME}:${last_version}" "${IMAGE_NAME}:latest" 2>/dev/null || true
fi

echo ""
echo "Build summary:"
echo "  Total: ${#VERSIONS[@]}"
echo "  Success: $((${#VERSIONS[@]} - ${#failed_builds[@]}))"
echo "  Failed: ${#failed_builds[@]}"

if [ ${#failed_builds[@]} -gt 0 ]; then
    echo ""
    echo "Failed versions:"
    for i in "${!failed_builds[@]}"; do
        echo "  ${failed_builds[$i]}"
        echo "    ${failed_errors[$i]}" | head -1
    done
    exit 1
fi

exit 0

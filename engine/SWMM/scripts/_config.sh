# Docker image configuration
IMAGE_NAME="swmm"
REGISTRY="neeraip/swmm"

# Array of SWMM versions from https://github.com/USEPA/Stormwater-Management-Model/tags
# Stored without 'v' prefix; 'v' is added when building from GitHub
# NOTE: Only v5.1.15+, v5.2.1+ versions are supported
#       - v5.1.14 and earlier have compilation errors (missing headers, etc.)
#       - v5.2.0 has undeclared HUGE in inlet.c
VERSIONS=(
    # "5.0.22"  # No CMakeLists.txt
    # "5.1.1"   # No CMakeLists.txt
    # "5.1.2"   # No CMakeLists.txt
    # "5.1.3"   # No CMakeLists.txt
    # "5.1.4"   # No CMakeLists.txt
    # "5.1.5"   # No CMakeLists.txt
    # "5.1.6"   # No CMakeLists.txt
    # "5.1.7"   # No CMakeLists.txt
    # "5.1.8"   # No CMakeLists.txt
    # "5.1.9"   # No CMakeLists.txt
    # "5.1.10"  # No CMakeLists.txt
    # "5.1.11"  # No CMakeLists.txt
    # "5.1.12"  # No CMakeLists.txt
    # "5.1.13"  # No CMakeLists.txt
    # "5.1.14"  # Missing #include <string.h>
    "5.1.15"
    # "5.2.0"   # Undeclared HUGE in inlet.c
    "5.2.1"
    "5.2.2"
    "5.2.3"
    "5.2.4"
)
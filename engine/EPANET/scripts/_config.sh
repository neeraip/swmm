# Docker image configuration
IMAGE_NAME="epanet"
REGISTRY="neeraip/epanet"

# Array of EPANET versions from https://github.com/OpenWaterAnalytics/EPANET/tags
# Stored without 'v' prefix; 'v' is added when building from GitHub
# NOTE: Versions 2.0.12 and 2.1 do not have CMakeLists.txt (use old build system)
#       Only v2.2+ are supported with modern CMAKE build
VERSIONS=(
    # "2.0.12"  # No CMakeLists.txt (legacy build system)
    # "2.1"     # No CMakeLists.txt (legacy build system)
    "2.2"
    "2.3"
    "2.3.1"
    "2.3.2"
    "2.3.3"
)

# Water Resources Modeling

Minimalist Docker containers for running hydraulic and hydrologic simulation engines. No bells and whistles—just containerized SWMM and EPANET.

## Overview

This repository provides:

- **SWMM** (Stormwater Management Model) - Multi-version Docker images (v5.1.15, v5.2.1-v5.2.4)
- **EPANET** (Water Network Analysis) - Multi-version Docker images (v2.2, v2.3-v2.3.3)
- **Simple entrypoints** - Run simulations with just input/output files
- **Multi-arch support** - Both amd64 and arm64 architectures
- **Supply chain attestations** - SBOM and provenance for Docker Hub

## Quick Start

### Run SWMM (Latest)

```bash
docker run -v $(pwd):/workspace neeraip/swmm:latest \
  input.inp output.rpt output.out
```

### Run EPANET (Latest)

```bash
docker run -v $(pwd):/workspace neeraip/epanet:latest \
  input.inp output.rpt output.out
```

### Or use Makefile

```bash
make swmm-build    # Build all SWMM versions
make swmm-test     # Test all versions
make swmm-push     # Push to Docker Hub

make epanet-build  # Build all EPANET versions
make epanet-test   # Test all versions
make epanet-push   # Push to Docker Hub
```

## Project Structure

```
water-resources-modeling/
├── engine/
│   ├── SWMM/
│   │   ├── Dockerfile          # Multi-stage build
│   │   ├── entrypoint.sh        # Input validation + error checking
│   │   ├── scripts/
│   │   │   ├── _config.sh       # Version configuration
│   │   │   ├── build-all-tags.sh   # Batch local build
│   │   │   ├── push-all-tags.sh    # Multi-arch push to Docker Hub
│   │   │   └── test-all-tags.sh    # Verify all versions
│   │   ├── data/
│   │   │   └── example.inp      # Test input file
│   │   └── README.md
│   ├── EPANET/
│   │   ├── Dockerfile
│   │   ├── entrypoint.sh
│   │   ├── scripts/
│   │   │   ├── _config.sh
│   │   │   ├── build-all-tags.sh
│   │   │   ├── push-all-tags.sh
│   │   │   └── test-all-tags.sh
│   │   ├── data/
│   │   │   └── example.inp
│   │   └── README.md
│   ├── HEC-HMS/
│   │   └── README.md            # Placeholder (not yet implemented)
│   └── HEC-RAS/
│       └── README.md            # Placeholder (not yet implemented)
├── data/                        # Shared test/example data
└── Makefile
```

## Common Tasks

### Build all SWMM versions locally

```bash
cd engine/SWMM/scripts
./build-all-tags.sh
```

### Build all EPANET versions locally

```bash
cd engine/EPANET/scripts
./build-all-tags.sh
```

### Build specific version

```bash
cd engine/SWMM
docker build --build-arg TAG=v5.2.3 -t swmm:5.2.3 .
```

## Testing

### Test all SWMM versions

```bash
cd engine/SWMM/scripts
./test-all-tags.sh
```

### Test all EPANET versions

```bash
cd engine/EPANET/scripts
./test-all-tags.sh
```

Output files are created with version suffixes (e.g., `example-5.2.4.rpt`).

## Pushing to Docker Hub

### Push all SWMM versions (multi-arch: amd64, arm64)

```bash
cd engine/SWMM/scripts
./push-all-tags.sh
```

Images pushed to: `neeraip/swmm:*`

### Push all EPANET versions (multi-arch: amd64, arm64)

```bash
cd engine/EPANET/scripts
./push-all-tags.sh
```

Images pushed to: `neeraip/epanet:*`

Both include SBOM and provenance attestations.

## Usage

### Basic run

```bash
docker run -v $(pwd):/workspace <image>:<tag> input.inp output.rpt
```

### With binary output

```bash
docker run -v $(pwd):/workspace <image>:<tag> input.inp output.rpt output.out
```

### With debug logging

```bash
docker run -e DEBUG=1 -v $(pwd):/workspace <image>:<tag> input.inp output.rpt
```

## Configuration

Each engine has a `scripts/_config.sh` that controls:
- `IMAGE_NAME` - Local image name (swmm/epanet)
- `REGISTRY` - Docker Hub registry (neeraip/swmm, neeraip/epanet)
- `VERSIONS` - Array of supported versions

Edit these files to customize builds or add new versions.

## How It Works

### Dockerfile Pattern

1. **Builder stage** - Debian bookworm, clone from GitHub, compile with CMake
2. **Runtime stage** - Debian bookworm-slim, copy binaries, set LD_LIBRARY_PATH
3. **Non-root user** - `simulator` user for security
4. **Entrypoint** - Validates inputs, runs simulation, checks for errors

### Entrypoint Script

- Validates input file exists
- Runs the simulation binary
- Scans output report for ERROR keyword (engines exit 0 on failure)
- Verifies output files created
- Supports `DEBUG` environment variable for logging

### Multi-arch Support

All images built for `linux/amd64` and `linux/arm64` using `docker buildx`.

## Supported Versions

### SWMM

- v5.1.15
- v5.2.1
- v5.2.2
- v5.2.3
- v5.2.4 (latest)

### EPANET

- v2.2
- v2.3
- v2.3.1
- v2.3.2
- v2.3.3 (latest)

## License

- **SWMM** - Public Domain (EPA)
- **EPANET** - Public Domain (EPA)
- **This repo** - MIT

# SWMM Engine

Docker container setup for SWMM (Stormwater Management Model) hydraulic analysis engine.

## Supported Versions

- 5.1.15
- 5.2.1
- 5.2.2
- 5.2.3
- 5.2.4

## Building

Build all versions locally:

```bash
cd engine/SWMM/scripts
./build-all-tags.sh
```

## Testing

Test all built versions:

```bash
cd engine/SWMM/scripts
./test-all-tags.sh
```

## Pushing to Docker Hub

Push all versions to Docker Hub with multi-arch support (amd64, arm64):

```bash
cd engine/SWMM/scripts
./push-all-tags.sh
```

## Usage

Run a simulation:

```bash
docker run -v $(pwd):/workspace swmm:5.2.4 input.inp output.rpt output.out
```

### Arguments

- `input.inp` - Input file (stormwater network file)
- `output.rpt` - Report file output path
- `output.out` - Optional binary output file

### Environment Variables

- `DEBUG` - Set to "1" or "true" for detailed logging (optional)

## Configuration

Edit `scripts/_config.sh` to:
- Change image name: `IMAGE_NAME`
- Change registry: `REGISTRY`
- Add/remove versions: `VERSIONS` array

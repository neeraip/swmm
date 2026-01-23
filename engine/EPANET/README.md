# EPANET Engine

Docker container setup for EPANET water network analysis engine.

## Supported Versions

- 2.2
- 2.3
- 2.3.1
- 2.3.2
- 2.3.3

**Note:** Versions 2.0.12 and 2.1 use a legacy build system without CMakeLists.txt and are not supported.

## Building

Build all versions locally:

```bash
cd engine/EPANET/scripts
./build-all-tags.sh
```

## Testing

Test all built versions:

```bash
cd engine/EPANET/scripts
./test-all-tags.sh
```

## Pushing to Docker Hub

Push all versions to Docker Hub with multi-arch support (amd64, arm64):

```bash
cd engine/EPANET/scripts
./push-all-tags.sh
```

## Usage

Run a simulation:

```bash
docker run -v $(pwd):/workspace epanet:2.3.3 input.inp output.rpt output.out
```

### Arguments

- `input.inp` - Input file (water network file)
- `output.rpt` - Report file output path
- `output.out` - Optional binary output file

### Environment Variables

- `DEBUG` - Set to "1" or "true" for detailed logging (optional)

## Configuration

Edit `scripts/_config.sh` to:
- Change image name: `IMAGE_NAME`
- Change registry: `REGISTRY`
- Add/remove versions: `VERSIONS` array

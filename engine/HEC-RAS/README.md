# HEC-RAS Engine

Docker container setup for HEC-RAS hydraulic analysis engine.

## Supported Versions

- 6.6

## Building

HEC-RAS must be built on an amd64 host (native x86_64). Build-time Wine and winetricks steps cannot run under arm64/QEMU emulation, even if the build platform is set to amd64.

Build all versions locally:

```bash
cd engine/HEC-RAS/scripts
./build-all-tags.sh
```

## Testing

Test all built versions:

```bash
cd engine/HEC-RAS/scripts
./test-all-tags.sh
```

## Pushing to Docker Hub

Push all versions to Docker Hub (amd64 only):

```bash
cd engine/HEC-RAS/scripts
./push-all-tags.sh
```

## Usage

Start a dev container:

```bash
cd engine/HEC-RAS
docker compose up
```

Run a Python script inside the container (example):

```bash
docker exec -it hec-ras python3 /data/test.py
```

### Notes

- HEC-RAS binaries are expected under `bin/<version>/` and are copied into the Wine prefix at build time.
- Wine components (dotnet48, gdiplus, corefonts) are installed during the image build; this requires an amd64 host.

## Configuration

Edit `scripts/_config.sh` to:
- Change image name: `IMAGE_NAME`
- Change registry: `REGISTRY`
- Add/remove versions: `VERSIONS` array

# Builder stage - compile EPANET
FROM ubuntu:26.04 AS builder

WORKDIR /src

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone and build EPANET
ARG TAG=v2.3.3
RUN git clone --branch ${TAG} https://github.com/OpenWaterAnalytics/EPANET.git EPANET && \
    cd EPANET && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    cmake --build . --config Release

# Runtime stage
FROM ubuntu:26.04

WORKDIR /workspace

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create bin directory for binaries and libraries
RUN mkdir -p /app/bin

# Copy built binaries and libraries from builder
COPY --from=builder /src/EPANET/build/bin/. /app/bin/
COPY --from=builder /src/EPANET/build/lib/. /app/bin/
COPY --from=builder /src/EPANET/build/src/outfile/. /app/bin/

# Make binary executable and register libraries
RUN chmod +x /app/bin/runepanet 2>/dev/null || true && \
    ldconfig /app/bin 2>/dev/null || true && \
    ln -sf /app/bin/runepanet /app/bin/epanet || true

# Copy entrypoint script
COPY engine/EPANET/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create non-root user
RUN useradd -m -s /bin/bash simulator && \
    chown -R simulator:simulator /workspace /app

# Switch to non-root user
USER simulator

# Set library path for EPANET runtime dependencies
ENV LD_LIBRARY_PATH=/app/bin
ENV PATH=/app/bin:$PATH

ENTRYPOINT ["/entrypoint.sh"]

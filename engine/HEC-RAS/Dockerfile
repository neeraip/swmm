FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    WINEARCH=win64 \
    WINEPREFIX=/root/.wine \
    WINEDEBUG=-all \
    XDG_RUNTIME_DIR=/tmp/runtime-root

# Select HEC-RAS version to include
ARG HEC_RAS_VERSION=6.6
ENV HEC_RAS_HOME=/root/.wine/drive_c/HEC-RAS/${HEC_RAS_VERSION}

# Install system dependencies and Wine
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    cabextract \
    python3 \
    python3-venv \
    python3-pip \
    winbind \
    wine64 \
    wine32 \
    winetricks \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Create runtime directory and install Python packages in a venv
RUN mkdir -p /tmp/runtime-root \
    && python3 -m venv --upgrade-deps /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir ras-commander

ENV PATH="/opt/venv/bin:$PATH"

# Initialize Wine prefix and install components at runtime (not build-time)

# Copy the preinstalled HEC-RAS binaries from the repo into the Wine drive.
COPY ./bin/${HEC_RAS_VERSION}/ /root/.wine/drive_c/HEC-RAS/${HEC_RAS_VERSION}/

# Set working directory and copy run script
WORKDIR /app
COPY run.py /app/run.py

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]





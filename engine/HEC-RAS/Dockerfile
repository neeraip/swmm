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

# Initialize Wine prefix
RUN xvfb-run -a wineboot --init

# Install Wine components (split for better caching and error visibility)
RUN xvfb-run -a winetricks -q corefonts

RUN xvfb-run -a winetricks -q gdiplus

RUN xvfb-run -a winetricks -q dotnet48

# Copy the preinstalled HEC-RAS binaries from the repo into the Wine drive.
COPY ./bin/${HEC_RAS_VERSION}/ /root/.wine/drive_c/HEC-RAS/${HEC_RAS_VERSION}/

ENTRYPOINT ["python3"]





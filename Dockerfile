FROM ubuntu:24.04

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    curl \\
    git \\
    sudo \\
    xz-utils \\
    ca-certificates \\
    && rm -rf /var/lib/apt/lists/*

# Create non-root hermes user with sudo privileges
RUN useradd -m -s /bin/bash hermes && \\
    echo "hermes ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hermes && \\
    chmod 0440 /etc/sudoers.d/hermes

# Switch to hermes user
USER hermes
WORKDIR /home/hermes

# Install Hermes Agent via official install script
RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Ensure hermes binary is on PATH
ENV PATH="/home/hermes/.local/bin:$PATH"

# Copy entrypoint script
COPY --chown=hermes:hermes entrypoint.sh /home/hermes/entrypoint.sh
RUN chmod +x /home/hermes/entrypoint.sh

# Persist Hermes config and data across container restarts
VOLUME ["/home/hermes/.hermes"]

ENTRYPOINT ["/home/hermes/entrypoint.sh"]
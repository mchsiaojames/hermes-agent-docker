FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages + supervisord
RUN apt-get update && apt-get install -y curl git sudo xz-utils ca-certificates supervisor && rm -rf /var/lib/apt/lists/*

# Create hermes user with sudo
RUN useradd -m -s /bin/bash hermes && echo "hermes ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hermes && chmod 0440 /etc/sudoers.d/hermes

# Install Hermes Agent as hermes user
USER hermes
WORKDIR /home/hermes
RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
ENV PATH="/home/hermes/.local/bin:$PATH"

USER root

# Copy supervisord config
RUN mkdir -p /etc/supervisor/conf.d /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Persist hermes config across restarts
VOLUME ["/home/hermes/.hermes"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

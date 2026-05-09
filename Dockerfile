FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages: SSH, supervisord, hermes dependencies
RUN apt-get update && apt-get install -y curl git sudo xz-utils ca-certificates openssh-server supervisor && rm -rf /var/lib/apt/lists/*

# Create non-root hermes user with sudo
RUN useradd -m -s /bin/bash hermes && echo "hermes ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hermes && chmod 0440 /etc/sudoers.d/hermes

# Set a default SSH password (user should change this after first login)
RUN echo "hermes:hermes" | chpasswd

# Configure SSH - allow password auth, allow hermes user
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Install Hermes Agent as hermes user
USER hermes
WORKDIR /home/hermes
RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
ENV PATH="/home/hermes/.local/bin:$PATH"

# Switch back to root for supervisord setup
USER root

# supervisord config
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Persist hermes config across restarts
VOLUME ["/home/hermes/.hermes"]

# SSH port
EXPOSE 22

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

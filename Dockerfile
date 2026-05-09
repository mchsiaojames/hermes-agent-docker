FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages + SSH + supervisord + ufw
RUN apt-get update && apt-get install -y curl git sudo xz-utils ca-certificates openssh-server supervisor ufw iptables && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create hermes user with sudo
RUN useradd -m -s /bin/bash hermes && echo "hermes ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hermes && chmod 0440 /etc/sudoers.d/hermes

# Default SSH password - change after first login
RUN echo "hermes:hermes" | chpasswd

# Configure SSH
RUN mkdir -p /var/run/sshd /var/run/tailscale
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Install Hermes Agent as hermes user
USER hermes
WORKDIR /home/hermes
RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
ENV PATH="/home/hermes/.local/bin:$PATH"

USER root

# Copy config files
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY lockdown-ssh.sh /usr/local/bin/lockdown-ssh
RUN chmod +x /usr/local/bin/lockdown-ssh

# Persist hermes config and tailscale state
VOLUME ["/home/hermes/.hermes", "/var/lib/tailscale"]

EXPOSE 22

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

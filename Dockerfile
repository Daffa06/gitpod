# from image 
FROM ubuntu:24.04

# user
USER root

# setup env
ARG UBUNTU_FRONTEND=noninteractive

# package
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install -y git fish sudo openssl openssh-client bc bison build-essential ccache curl flex glibc-source g++-multilib gcc-multilib gnupg neofetch && \
    tmate rsync schedtool python2 tmate ssh

# Added ARG for email and user variables
ARG EMAIL USER
ENV EMAIL=${EMAIL} USER=${USER}
    
# add user
ARG USER=default_user
RUN useradd -m -p $(openssl passwd -1 "0000") -U "$USER"

# Copy and run the script set_password.sh
COPY set_password.sh /tmp/
RUN chmod +rwx /tmp/set_password.sh && /tmp/set_password.sh

# git config
RUN git config --global user.email "$EMAIL" && \
    git config --global user.name "$USER"

# generate SSH key
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t ed25519 -C "gitpod@user.com" -f /root/.ssh/id_ed25519 -N ''

# evaluate ssh-agent and add SSH key
RUN eval `ssh-agent -s` && \
    ssh-add /root/.ssh/id_ed25519

# sudo hax
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /usr/bin/fish -p gitpod gitpod \
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    && chmod 0440 /etc/sudoers

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Set shell use bash
RUN chsh -s /bin/bash

# env bash
ENV SHELL /bin/bash

# Entry point: start with bash, then switch to fish
ENTRYPOINT ["/bin/bash", "-c", "fish"]

# Cache and environment configuration
ENV CACHE=1
RUN if [ "$CACHE" -eq 1 ]; then \
        ccache -M 256G && \
        export USE_CCACHE=1; \
    fi
ENV LC_ALL=C

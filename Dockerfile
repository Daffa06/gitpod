# from image 
FROM debian:latest

# user
USER root

# setup env
ARG DEBIAN_FRONTEND=noninteractive

# package
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y git fish sudo openssl openssh-client

# add user
RUN useradd -m -p $(openssl passwd -1 "0000") -U "${GITPOD_USER}"

# env from gitpod
ENV GIT_USER_EMAIL="${GITPOD_EMAIL}" \
    GIT_USER_NAME="${GITPOD_USER}"

# git config
RUN git config --global user.email "$GIT_USER_EMAIL" && \
    git config --global user.name "$GIT_USER_NAME"

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

# shell cmd
SHELL ["/usr/bin/fish", "-c"]

# set shell use fish
RUN chsh -s /usr/bin/fish

# env fish
ENV SHELL /usr/bin/fish

# entrypoint
ENTRYPOINT [ "fish" ]

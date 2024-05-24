# from image 
FROM daffa06/soulvibe-kernel:v1

# user
USER root

# Verify the presence and execute the script
RUN if [ -f /usr/src/packages_env.sh ]; then \
        chmod +x /usr/src/packages_env.sh && \
        /usr/src/packages_env.sh; \
    else \
        echo "packages_env.sh not found in base image"; \
    fi

# Added ARG for email and user variables
ARG EMAIL USER
ENV EMAIL=${EMAIL} USER=${USER}
    
# add user
RUN useradd -m -p $(openssl passwd -1 "0000") -U "$USER"

# Copy and run the script set_password.sh
COPY set_password.sh /tmp/
RUN chmod +rwx /tmp/set_password.sh && /tmp/set_password.sh

# git config
RUN git config --global user.email "$EMAIL" && \
    git config --global user.name "$USER"

# generate SSH key
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t ed25519 -C "$EMAIL" -f /root/.ssh/id_ed25519 -N ''

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

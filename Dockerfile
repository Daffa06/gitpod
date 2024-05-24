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

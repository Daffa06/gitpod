# from image 
FROM debian:latest

# user
USER root

# setup env
ARG DEBIAN_FRONTEND=noninteractive

# package
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y git fish sudo openssl

# add user
RUN useradd -m -p $(openssl passwd -1 "0000") -U Daffa06

# script paswd
COPY set_password.sh /
RUN chmod +x /set_password.sh && /set_password.sh

# add paswd
RUN echo 'root:0000' | chpasswd

# sudo    
RUN sudo passwd

# git config
RUN git config --global user.email "kumaraprastya@gmail.com"
RUN git config --global user.name "Daffa06"

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

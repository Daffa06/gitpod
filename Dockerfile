# from image 
FROM debian:latest

# user
USER root

# setup env
ARG DEBIAN_FRONTEND=noninteractive

# remove file apt lock
RUN rm -rf /var/lib/apt/lists/*

# fix missing file
RUN apt-get update --fix-missing

# package
RUN apt-get update -qq && apt-get upgrade -y && apt-get install --no-install-recommends -y \
    apt-get install -y git

# fish terminal add
RUN apt-get update && apt-get install -y fish

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

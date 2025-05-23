FROM ubuntu:24.04

### base ###
RUN yes | unminimize apt-get update && apt-get install -yq \
    zip \
    unzip \
    build-essential \
    clang \
    htop \
    curl \
    wget \
    bc \
    bison \
    make \
    xz-utils \
    locales \
    git \
    git-lfs \
    nano \
    sudo \
    time \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8

### set user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/hlong -s /bin/bash -p hlong hlong \
    # Remove `use_pty` option and enable passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e '/Defaults\tuse_pty/d' -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
    # To emulate the workspace-session behavior within dazzle build env
    && mkdir /workspace && chown -hR hlong:hlong /workspace

ENV HOME=/home/hlong
WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" ; } >> .bashrc

# configure git-lfs
RUN git lfs install --system --skip-repo

### set user (2) ###
USER hlong
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for hlong: success" && \
    # create .bashrc.d folder and source it in the bashrc
    mkdir -p /home/hlong/.bashrc.d && \
    (echo; echo "for i in \$(ls -A \$HOME/.bashrc.d/); do source \$HOME/.bashrc.d/\$i; done"; echo) >> /home/hlong/.bashrc && \
    # create a completions dir for hlong user
    mkdir -p /home/hlong/.local/share/bash-completion/completions

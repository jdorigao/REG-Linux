FROM ubuntu:noble-20250910

ARG DEBIAN_FRONTEND=noninteractive

# The container has no package lists, so need to update first
RUN apt-get -o APT::Retries=3 update -y

RUN apt-get -o APT::Retries=3 install -y --no-install-recommends \
    bc \
    build-essential \
    bzr \
    ca-certificates \
    cmake \
    cpio \
    curl \
    cvs \
    file \
    g++ \
    g++-multilib \
    gcc \
    gcc-multilib \
    git \
    libssl-dev \
    locales \
    mercurial \
    patch \
    rsync \
    shellcheck \
    subversion \
    unzip \
    wget \
    && \
    apt-get remove -y '*cloud*' '*firefox*' '*chrome*' '*dotnet*' '*php*' && \
    apt-get -y autoremove && \
    apt-get -y clean

# To be able to generate a toolchain with locales, enable one UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=Europe/Paris

RUN mkdir -p /build
WORKDIR /build

CMD ["/bin/bash"]

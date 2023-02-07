
#ubuntu
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV GIT_SSL_NO_VERIFY=1
ENV FORCE_UNSAFE_CONFIGURE=1

#RUN sed -i s:/archive.ubuntu.com:/mirrors.tuna.tsinghua.edu.cn/ubuntu:g /etc/apt/sources.list
#RUN apt-get clean

RUN apt-get -y update --fix-missing && \
    apt-get install -y \
    ecj \
    git \
    vim \
    npm \
    g++ \
    gcc \
    file \
    swig \
    wget \
    time \
    make \
    curl \
    cmake \
    gawk \
    unzip \
    rsync \
    ccache \
    fastjar \
    gettext \
    xsltproc \
    apt-utils \
    libssl-dev \
    libelf-dev \
    zlib1g-dev \
    subversion \
    build-essential \
    libncurses5-dev \
    libncursesw5-dev \
    python \
    python3 \
    python3-dev \
    python2.7-dev \
    python3-setuptools \
    python-distutils-extra \
    java-propose-classpath \
    && apt-get clean


WORKDIR /home

RUN git clone --recursive https://github.com/Mleaf/openwrt.git

WORKDIR /home/openwrt

RUN ./scripts/feeds update -a \
    && ./scripts/feeds install -a

RUN rm -f .config* && touch .config && \
    echo "CONFIG_HOST_OS_LINUX=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx_generic=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx_generic_DEVICE_canbox_cm520-79f=y" >> .config && \
    echo "CONFIG_TARGET_ROOTFS_INITRAMFS=y" >> .config && \
    echo "CONFIG_SDK=y" >> .config && \
    echo "CONFIG_MAKE_TOOLCHAIN=y" >> .config && \
    echo "CONFIG_IB=y" >> .config && \
    echo "CONFIG_PACKAGE_vim=y" >> .config && \
    echo "CONFIG_PACKAGE_bash=y" >> .config && \
    echo "CONFIG_PACKAGE_wget=y" >> .config && \
    echo "CONFIG_PACKAGE_ethtool=y" >> .config \
    sed -i 's/^[ \t]*//g' .config && \
    make defconfig

RUN make download -j8 \
    && make -j1 V=w

WORKDIR /home
CMD [ "/bin/bash" ]

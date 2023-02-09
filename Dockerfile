
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

RUN git clone -b openwrt-21.02 --recursive https://github.com/openwrt/openwrt.git

WORKDIR /home/openwrt

RUN ./scripts/feeds update -a \
    && ./scripts/feeds install -a

COPY ./qcom-ipq4019-cm520-79f.dts ./target/linux/ipq40xx/files/arch/arm/boot/dts/qcom-ipq4019-cm520-79f.dts

RUN rm -f .config* && touch .config && \
    echo "CONFIG_HOST_OS_LINUX=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx_generic=y" >> .config && \
    echo "CONFIG_TARGET_ipq40xx_generic_DEVICE_mobipromo_cm520-79f=y" >> .config && \
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
    && make -j1 V=w \
    && tar -jxvf ./bin/targets/ipq40xx/generic/openwrt-toolchain-ipq40xx-generic_gcc-8.4.0_musl_eabi.Linux-x86_64.tar.bz2 -C /opt/ \
    && tar -Jxvf ./bin/targets/ipq40xx/generic/openwrt-imagebuilder-ipq40xx-generic.Linux-x86_64.tar.xz -C /home/ \
    && mkdir -p /opt/Kernel-ipq40xx \
    && mv build_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/linux-ipq40xx_generic/linux-5.4.230/ /opt/Kernel-ipq40xx \
    && cd /home && rm -rf ./openwrt

ENV ARCH=arm
ENV CROSS_COMPILE=/opt/openwrt-toolchain-ipq40xx-generic_gcc-8.4.0_musl_eabi.Linux-x86_64/toolchain-arm_cortex-a7+neon-vfpv4_gcc-8.4.0_musl_eabi/bin/arm-openwrt-linux-
ENV STAGING_DIR=/opt/openwrt-toolchain-ipq40xx-generic_gcc-8.4.0_musl_eabi.Linux-x86_64/toolchain-arm_cortex-a7+neon-vfpv4_gcc-8.4.0_musl_eabi/bin

WORKDIR /home/openwrt-imagebuilder-ipq40xx-generic.Linux-x86_64

RUN make image PROFILE="mobipromo_cm520-79f" PACKAGES="wget vim bash"

WORKDIR /home

CMD [ "/bin/bash" ]

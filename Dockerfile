FROM ghcr.io/promisc/frida-toolchain-linux-armhf:5b9d256f-glibc_2_19 as frida-builder

# Deps from https://github.com/frida/frida-ci/blob/master/images/worker-ubuntu-20.04-x86_64/Dockerfile
USER root
WORKDIR /root
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        coreutils \
        curl \
        file \
        git \
        lib32stdc++-9-dev \
        libc6-dev-i386 \
        libgl1-mesa-dev \
        locales \
        nodejs \
        npm \
        p7zip \
        python3-dev \
        python3-pip \
        python3-requests \
        python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

USER builder
WORKDIR /home/builder
RUN git clone --recurse-submodules https://github.com/frida/frida
WORKDIR /home/builder/frida
RUN git checkout 5b9d256f645a2c76ccc2941ba7d1e67370143da0 \
    && git submodule update \
    && sed -i 's,FRIDA_V8 ?= auto,FRIDA_V8 ?= disabled,' config.mk \
    && sed -i 's,host_arch_flags="-march=armv7-a",host_arch_flags="-march=armv7-a -mfloat-abi=hard -mfpu=vfpv3-d16",g' releng/setup-env.sh \
    && mkdir -p build \
    && mv /home/builder/toolchain-linux-armhf.tar.bz2 /home/builder/frida/build/ \
    && mv /home/builder/sdk-linux-armhf.tar.bz2 /home/builder/frida/build/
ENV FRIDA_HOST=linux-armhf
ENV PATH=${PATH}:/home/builder/x-tools/arm-linux-gnueabihf/bin

FROM frida-builder as frida-core-builder
USER builder
WORKDIR /home/builder/frida
RUN make core-linux-armhf
# RUN make check-core-linux-armhf

FROM ubuntu:20.04 as final-frida-core-image
RUN adduser --disabled-password --gecos '' builder
USER builder
WORKDIR /home/builder
COPY --from=frida-core-builder --chown=builder:builder /home/builder/frida/build/frida_thin-linux-armhf/bin/frida-server /home/builder/
COPY --from=frida-core-builder --chown=builder:builder /home/builder/frida/build/frida_thin-linux-armhf/bin/frida-inject /home/builder/
COPY --from=frida-core-builder --chown=builder:builder /home/builder/frida/build/frida_thin-linux-armhf/lib/frida/32/frida-gadget.so /home/builder/

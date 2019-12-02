# Start with Ubuntu 18.04
FROM ubuntu:18.04

# Separate the working area
WORKDIR /app

# Add ENV variables accessible everywhere
ENV SDKPATH=/app/AmbiqSuiteSDK
ENV COMMONPATH=/app/AmbiqSuiteSDK/boards_sfe/common

# Add ARG variables to be used only in the build
ARG BUILD_INFO=/build-info.txt

# ARMGCC is ADDed from a web url, the file is decompressed + extracted based on a wildcard matching pattern, and the name of the resulting directory must be added to the path
ARG ARMGCC_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
ARG ARMGCC_DWNLD_MATCH=gcc-arm-none-eabi*.tar.bz2
ARG ARMGCC_PATH=gcc-arm-none-eabi-8-2018-q4-major

# Create a build log
RUN touch ${BUILD_INFO} && \
  echo "Build created on: " >> ${BUILD_INFO} && \
  date >> ${BUILD_INFO} && \
  echo "" >> ${BUILD_INFO}

# Install necessary apt packages
RUN echo "Installing Packages" && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends \
  build-essential \
  git \
  python3-pip \
  && rm -rf /var/lib/apt/lists/* && \
  echo ""

RUN echo "Installed packages: " >> ${BUILD_INFO} && \
  make --version | head -n 1 >> ${BUILD_INFO} && \
  git --version >> ${BUILD_INFO} && \
  python3 --version >> ${BUILD_INFO} && \
  pip3 --version >> ${BUILD_INFO} && \
  echo "" >> ${BUILD_INFO}

# Install ARM Embedded Toolchain
ADD ${ARMGCC_URL} /tmp/
RUN echo "Installing ARM Cross Compiler" && \
  tar -xvjf /tmp/${ARMGCC_DWNLD_MATCH} -C /bin/ && \
  rm -rf /tmp/* && \
  echo ""

ENV PATH="/bin/${ARMGCC_PATH}/bin:${PATH}"

# Install Python Packages
RUN echo "Installing Python Packages" && \
  pip3 install --upgrade pyserial && \
  pip3 install --upgrade pycryptodome && \
  echo ""

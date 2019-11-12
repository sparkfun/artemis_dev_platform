# Start with Ubuntu 18.04
FROM ubuntu:18.04



# Add ARG variables to be used only in the build

# ARMGCC is ADDed from a web url, the file is decompressed + extracted based on a wildcard matching pattern, and the name of the resulting directory must be added to the path
ARG ARMGCC_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2?revision=ab7c81a3-cba3-43be-af9d-e922098961dd?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2018-q4-major
ARG ARMGCC_DWNLD_MATCH=gcc-arm-none-eabi*.tar.bz2
ARG ARMGCC_PATH=gcc-arm-none-eabi-8-2018-q4-major

# The SparkFun
ARG AMSDK_REPO=https://github.com/sparkfun/AmbiqSuiteSDK



# Add ENV variables for both build and container use
ENV AMSDK /home/AmbiqSuiteSDK



# Create a build log
RUN touch /build-info.txt
RUN echo "Build created on: " >> /build-info.txt
RUN date >> /build-info.txt



# Install necessary apt packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Installed packages: " >> /build-info.txt && \
    make --version >> /build-info.txt && \
    git --version >> /build-info.txt && \
    python3 --version >> /build-info.txt



# # Install ARM Embedded Toolchain
# ADD ${ARMGCC_URL} /tmp/
# RUN tar -xvjf /tmp/${ARMGCC_DWNLD_MATCH} -C /bin/ && \
#     rm -rf /tmp/*

# ENV PATH="/bin/${ARMGCC_PATH}/bin:${PATH}"


# RUN apt-get install ca-certificates
RUN update-ca-certificates

# Clone the AmbiqSuiteSDK w/ BSP package from SparkFun
RUN git clone --recursive ${AMSDK_REPO} ${AMSDK}

# Imagen de Nvidia con HPC 24.1
FROM nvcr.io/nvidia/nvhpc:24.1-devel-cuda12.3-ubuntu22.04

# Arquitectura de la GPU y CUDA
ARG ARQUITECTURA=86
ARG CUDA=12.3

# Actualización de paquetes
RUN apt-get update

# Instalación de dependencias necesarias
RUN apt-get install -y --no-install-recommends \
    apt-utils \
    autoconf \
    build-essential \
    quantum-espresso \
    ca-certificates \
    gfortran \
    libblas3 \
    libc6 \
    libfftw3-dev \
    libgcc-s1 \
    liblapack-dev \
    less \
    python3 \
    fftw3 \
    mpich \
    libatlas-base-dev \
    openmpi-bin \
    libopenmpi-dev \
    libscalapack-openmpi-dev \
    libelpa17 \
    wget

# Descarga y descompresión de Quantum ESPRESSO
RUN cd /root && \
    wget https://gitlab.com/QEF/q-e/-/archive/qe-7.2/q-e-qe-7.2.tar.gz && \
    tar -zxvf q-e-qe-7.2.tar.gz && \
    rm q-e-qe-7.2.tar.gz

# Configuración y compilación de Quantum ESPRESSO
RUN cd /root/q-e-qe-7.2 && \
    ./configure \
        --with-cuda=/opt/nvidia/hpc_sdk \
        --with-cuda-cc=${ARQUITECTURA} \
        --with-cuda-runtime=${CUDA} \
        --disable-parallel \
        --enable-openmp \
        --with-scalapack=no && \
    make all

# Generación de variable de Quantum ESPRESSO
RUN echo 'export PATH="/root/q-e-qe-7.2/bin:$PATH"' >> ~/.bashrc

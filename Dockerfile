FROM nvidia/cuda:12.6.3-runtime-rockylinux9 AS builder
USER root
RUN mkdir -v /dist

RUN dnf update -y && \
    dnf upgrade --refresh -y && \
    dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release


RUN  dnf install -y gcc make cmake nano zip \
    git git-lfs wget curl mlocate --allowerasing

RUN dnf install  -y \
  make gcc patch zlib-devel bzip2 bzip2-devel \
  readline-devel sqlite sqlite-devel openssl-devel \
  tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
ENV HOME=/root \
    PATH=/root/.local/bin:$PATH

# Pyenv
RUN curl https://pyenv.run | bash
ENV PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH

ARG PYTHON_VERSION=3.10.12

# Python
RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pyenv rehash && \
    pip install --no-cache-dir --upgrade pip setuptools wheel

# Install dependencies for tiny-cuda-nn

RUN dnf install cuda-toolkit-12 -y




FROM scratch
WORKDIR /
COPY --from=builder /dist/ /usr/local/lib/python3.10/site-packages/

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

ENV CUDA_HOME=/usr/local/cuda-12.9
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

RUN dnf install mlocate -y

RUN pip uninstall torch torchvision functorch tinycudann

RUN cd /tmp && mkdir tinycudann && cd tinycudann && \
    updatedb && \
    locate cuda-12 \

RUN pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121

RUN cd /tmp/tunycudann &&\
    git clone --recursive https://github.com/nvlabs/tiny-cuda-nn && \
    cd tiny-cuda-nn && \
    cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    cmake --build build --config RelWithDebInfo -j$(nproc)

RUN cd /tmp/tunycudann/tiny-cuda-nn/bindings/torch && \
    python setup.py install

FROM scratch
WORKDIR /
COPY --from=builder /dist/ /usr/local/lib/python3.10/site-packages/


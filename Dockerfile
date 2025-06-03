FROM nvidia/cuda:12.6.3-runtime-rockylinux9

USER root

ENV TZ=Europe/Zagreb

RUN mkdir -p /data && chmod -R 777 /data

WORKDIR /setup
COPY ./setup/deps.sh /setup/deps.sh

RUN chmod +x /setup/*.sh

RUN dnf update -y && \
    dnf upgrade --refresh -y && \
    dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release


RUN dnf install -y gcc make cmake nano zip \
    git git-lfs wget curl mlocate \
    make gcc patch zlib-devel bzip2 bzip2-devel \
    readline-devel sqlite sqlite-devel openssl-devel \
    tk-devel libffi-devel xz-devel \
    libuuid-devel gdbm-libs libnsl2 \
    mesa-libGLU \
    mlocate ninja-build \
     --allowerasing && \
    /usr/bin/crb enable && \
    dnf update -y  && \
    dnf groupinstall -y "Development Tools" && \
    /usr/bin/git lfs install

RUN bash /setup/deps.sh

ENV TCNN_CUDA_ARCHITECTURES=86

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

RUN dnf install -y nvidia-container-toolkit --allowerasing


RUN pip uninstall torch torchvision functorch tinycudann numpy

RUN cd /tmp && mkdir tinycudann && cd tinycudann && \
    updatedb

RUN dnf install -y cuda-nvcc-12-1 cuda-toolkit-12-1

RUN pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121


# Set environment variables
ENV CUDA_HOME=/usr/local/cuda-12.1
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$CUDA_HOME/lib:$LD_LIBRARY_PATH

RUN updatedb



#RUN cd /tmp/tinycudann &&\
#    git clone --recursive https://github.com/nvlabs/tiny-cuda-nn && \
#    cd tiny-cuda-nn && \
#    cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#    cmake --build build --config RelWithDebInfo -j$(nproc)
#
#
#



RUN cd /tmp/tinycudann &&\
    git clone --recursive https://github.com/nvlabs/tiny-cuda-nn && \
    cd tiny-cuda-nn && \
    cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    cmake --build build --config RelWithDebInfo -j$(nproc)

RUN pip install build

RUN cd /tmp/tinycudann/tiny-cuda-nn/bindings/torch && \
    python -m build


#RUN mkdir /opt/dist && chmod -R 777 /opt/dist
#RUN cp -rv /root/.pyenv/versions/3.10.12/lib/python3.10/site-packages/tinycudann*/ /opt/dist

CMD ["bash", "/setup/run.sh"]
##FROM nvidia/cuda:12.6.3-runtime-rockylinux9 AS system
#WORKDIR /
#COPY --from=builder /dist/ /usr/local/lib/python3.10/site-packages/
#COPY --from=builder /tmp/tinycudann/tiny-cuda-nn/bindings/torch /tmp/tinycudann/tiny-cuda-nn/bindings/torch



FROM nvidia/cuda:12.6.3-runtime-rockylinux9 AS builder
USER root
RUN mkdir -v /dist

RUN dnf update -y && \
    dnf install -y gcc make cmake

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Install dependencies for tiny-cuda-nn
RUN dnf install -y git python3 python3-pip
RUN pip3 install torch==2.1.2+cu121 torchvision==0.16.2+cu121 --extra-index-url https://download.pytorch.org/whl/cu121
RUN pip3 install ninja gsplat
RUN pip3 install git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch

#RUN cp -rv /opt/conda/lib/python3.10/site-packages/tinycudann*/ /dist



FROM scratch
WORKDIR /
COPY --from=builder /dist/ /usr/local/lib/python3.10/site-packages/

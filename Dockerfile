FROM nvidia/cuda:12.6.3-runtime-rockylinux9 as builder
USER root
RUN mkdir -v /dist
#RUN cp -rv /opt/conda/lib/python3.10/site-packages/tinycudann*/ /dist



FROM scratch
WORKDIR /
COPY --from=builder /dist/ /usr/local/lib/python3.10/site-packages/

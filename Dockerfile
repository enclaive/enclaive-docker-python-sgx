#premain
FROM ghcr.io/edgelesssys/edgelessrt-dev:latest AS marblerun

RUN git clone --branch=master --depth=1 https://github.com/edgelesssys/marblerun \
    && cd ./marblerun/ \
    && mkdir ./build/ \
    && cd ./build/ \
    && cmake .. \
    && make -j

#final 
FROM enclaive/gramine-os:jammy-7e9d6925

COPY --from=marblerun /marblerun/build/premain-libos /premain/

RUN apt-get update \
    && apt-get install -y  wget build-essential python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /manifest

COPY ./py.manifest.template /manifest/

RUN --mount=type=secret,id=signingkey gramine-manifest -Darch_libdir=/lib/x86_64-linux-gnu py.manifest.template py.manifest \
    && gramine-sgx-sign --key "/run/secrets/signingkey" --manifest py.manifest --output py.manifest.sgx \
    && gramine-sgx-get-token -s ./py.sig -o attributes \
    && cat ./attributes \
    && sed -i 's,https://localhost:8081/sgx/certification/v3/,https://172.17.0.1:8081/sgx/certification/v3/,g' /etc/sgx_default_qcnl.conf \
    && sed -i 's,"use_secure_cert": true,"use_secure_cert": false,g' /etc/sgx_default_qcnl.conf

EXPOSE 3306/tcp

# ENTRYPOINT [ "/app/entrypoint.sh" ]

FROM alpine AS builder

ENV TAIRHASH_URL https://github.com/alibaba/TairHash.git
# https://github.com/alibaba/TairHash/commit/209e5772d6bdc9e2597bc7192a8241f1ec65a10d
ENV GIT_HASH 209e5772d6bdc9e2597bc7192a8241f1ec65a10d
RUN set -ex; \
    \
    BUILD_DEPS=' \
    ca-certificates \
    cmake \
    gcc \
    git \
    g++ \
    make \
    '; \
    apt-get update; \
    apt-get install -y $BUILD_DEPS --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    git clone "$TAIRHASH_URL"; \
    cd TairHash; \
    git checekout "$GIT_HASH"; \
    mkdir -p build; \
    cd build; \
    cmake ..; \
    make -j; \
    cd ..; \
    cp lib/tairhash_module.so /usr/local/lib/;

FROM bitnami/redis:7.0.2-debian-11-r1

WORKDIR /data

COPY --from=builder /usr/local/lib/tairhash_module.so /usr/lib/redis/modules/

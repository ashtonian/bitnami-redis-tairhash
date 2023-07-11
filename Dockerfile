FROM debian:bullseye-slim AS builder

ENV TAIRHASH_URL https://github.com/alibaba/TairHash.git
# https://github.com/alibaba/TairHash/commit/209e5772d6bdc9e2597bc7192a8241f1ec65a10d
ENV GIT_HASH d213140c424c8f0759fd418d0d054dcbdd621b7b
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
    git checkout "$GIT_HASH"; \
    mkdir -p build; \
    cd build; \
    cmake ..; \
    make -j; \
    cd ..; \
    cp lib/tairhash_module.so /usr/local/lib/;

FROM bitnami/redis-cluster:7.0.12-debian-11-r1
RUN echo "loadmodule /usr/lib/redis/modules/tairhash_module.so"  >> /opt/bitnami/redis/etc/redis.conf

COPY --from=builder /usr/local/lib/tairhash_module.so /usr/lib/redis/modules/

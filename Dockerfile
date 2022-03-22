FROM rust:1.56.1 as builder

ARG NYM_VERSION="develop"
RUN git clone https://github.com/nymtech/nym.git && cd nym && git checkout $NYM_VERSION
RUN cargo install --path /nym/gateway

FROM debian:buster-slim
RUN apt-get update && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/nym-gateway /usr/local/bin/nym-gateway
ENTRYPOINT ["nym-gateway"]

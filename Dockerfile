FROM rust:latest AS builder

RUN rustup target add wasm32-unknown-unknown
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install --locked trunk
# ENV PATH="$PATH:/root/.cargo/bin"

WORKDIR /build-folder
ADD . ./
RUN trunk build --release \
    && cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:latest

RUN apk update \
    && apk add --no-cache libgcc \
    && rm -rf /var/cache/apk/*
 
COPY --from=builder /build-folder/dist/* /runtime/dist/
COPY --from=builder /build-folder/target/x86_64-unknown-linux-musl/server /runtime/

RUN addgroup -S shrimp \
    && adduser -S -g shrimp shrimp \
    && chown -R shrimp:shrimp /runtime

USER shrimp
WORKDIR /runtime
EXPOSE 3000
CMD ["./server"]
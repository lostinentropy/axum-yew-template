FROM alpine:latest AS builder

RUN apk update \
    && apk add cargo rust-wasm libressl-dev
RUN cargo install --locked wasm-bindgen-cli
RUN cargo install --locked trunk
ENV PATH="$PATH:/root/.cargo/bin"

WORKDIR /build-folder
ADD . ./
RUN trunk build --release \
    && cargo build --release

FROM alpine:latest

RUN apk update \
    && apk add --no-cache libgcc \
    && rm -rf /var/cache/apk/*

COPY --from=builder /build-folder/dist/* /runtime/dist/
COPY --from=builder /build-folder/target/release/server /runtime/

RUN addgroup -S shrimp \
    && adduser -S -g shrimp shrimp \
    && chown -R shrimp:shrimp /runtime

USER shrimp
WORKDIR /runtime
EXPOSE 3000
CMD ["./server"]
FROM debian:stable AS builder

RUN apt-get update

RUN apt-get install -y \
    build-essential \
    curl

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup target add wasm32-unknown-unknown
RUN cargo install trunk

WORKDIR /build-folder
ADD . ./
RUN trunk build --release \
    && cargo build --release

FROM debian:stable-slim
 
COPY --from=builder /build-folder/dist/* /runtime/dist/
COPY --from=builder /build-folder/target/release/server /runtime/server

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser
USER appuser

WORKDIR /runtime
EXPOSE 3000
CMD ["./server"]
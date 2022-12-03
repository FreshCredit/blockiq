FROM rust:1.65

COPY . /blockiq
WORKDIR /blockiq

# Install WebAssembly tools
RUN rustup target add wasm32-unknown-unknown
RUN rustup override set nightly
RUN rustup target add wasm32-unknown-unknown --toolchain nightly

#Install dependenties
RUN apt-get update
RUN apt install cmake -y
RUN apt install -y protobuf-compiler
RUN apt-get -y install clang

#Run build
RUN cargo build --release
RUN ./target/release/parachain-blockiq-node build-spec --disable-default-bootnode > plain-parachain-chainspec.json
RUN ./target/release/parachain-blockiq-node build-spec --chain plain-parachain-chainspec.json --disable-default-bootnode --raw > raw-parachain-chainspec.json
RUN ./target/release/parachain-blockiq-node export-genesis-state --chain raw-parachain-chainspec.json para-2000-genesis-stat
RUN ./target/release/parachain-blockiq-node export-genesis-wasm --chain raw-parachain-chainspec.json para-2000-wasm

#Start the app
CMD ./target/release/parachain-blockiq-node  --alice --collator --force-authoring --chain raw-parachain-chainspec.json --base-path /tmp/parachain/alice --port 40333 --ws-port 8844 -- --execution wasm --chain rococo-custom-3-raw.json --port 30343 --ws-port 9977

#Expose ports
EXPOSE 40333
EXPOSE 8844
EXPOSE 30343
EXPOSE 9977

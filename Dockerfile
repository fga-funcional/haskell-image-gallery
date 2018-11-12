FROM debian:latest

# Install dependencies.
RUN apt-get update && \
  apt-get install --assume-yes curl gcc libgmp-dev libpq-dev make xz-utils zlib1g-dev

# Install Stack.
RUN curl --location https://www.stackage.org/stack/linux-x86_64-static > stack.tar.gz && \
  tar xf stack.tar.gz && \
  cp stack-*-linux-x86_64-static/stack /usr/local/bin/stack && \
  rm -f -r stack.tar.gz stack-*-linux-x86_64-static/stack && \
  stack --version

WORKDIR /home/haskell-image-gallery
COPY haskell-image-gallery/package.yaml /home/haskell-image-gallery/
COPY haskell-image-gallery/stack.yaml /home/haskell-image-gallery/

RUN stack setup

COPY haskell-image-gallery /home/haskell-image-gallery/

RUN stack build --allow-different-user
RUN stack install

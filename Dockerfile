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

COPY haskell-image-gallery/haskell-image-gallery.cabal /home/haskell-image-gallery/haskell-image-gallery.cabal
COPY haskell-image-gallery/app /home/haskell-image-gallery/app
COPY haskell-image-gallery/src /home/haskell-image-gallery/src
COPY haskell-image-gallery/test /home/haskell-image-gallery/test
COPY haskell-image-gallery/Setup.hs /home/haskell-image-gallery/Setup.hs
COPY haskell-image-gallery/LICENSE /home/haskell-image-gallery/LICENSE
COPY haskell-image-gallery/README.md /home/haskell-image-gallery/README.md
COPY haskell-image-gallery/ChangeLog.md /home/haskell-image-gallery/ChangeLog.md

RUN stack build --allow-different-user

COPY haskell-image-gallery/application.conf /home/haskell-image-gallery/application.conf
COPY haskell-image-gallery/postgresql/ /home/haskell-image-gallery/postgresql

RUN stack install

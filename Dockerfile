FROM haskell:8.4.3

WORKDIR /home/haskell-image-gallery
COPY haskell-image-gallery/package.yaml /home/haskell-image-gallery/
COPY haskell-image-gallery/stack.yaml /home/haskell-image-gallery/

RUN stack setup

COPY haskell-image-gallery /home/haskell-image-gallery/

RUN stack build --allow-different-user
RUN stack install

CMD ['haskell-image-gallery-exe']

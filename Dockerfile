FROM haskell:8.4.3

WORKDIR /home/haskell-image-gallery
ADD haskell-image-gallery /home/haskell-image-gallery/

RUN stack setup
RUN stack build --allow-different-user
RUN stack install

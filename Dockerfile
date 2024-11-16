FROM debian:bullseye-slim

WORKDIR /app
# [1/6] installing build tools
RUN apt-get update && \
  apt-get install -y wget nano build-essential automake libtool
COPY ./mecab/jar .
# [2/6][mecab-ko] unziping
RUN tar xvfz mecab-0.996-ko-0.9.2.tar.gz
# [3/6][mecab-ko] build
RUN cd mecab-0.996-ko-0.9.2 \
  && ./configure \
  && make \
  && make check
# [4/6][mecab-ko] install and test
RUN cd mecab-0.996-ko-0.9.2 \
  && make install \
  && ldconfig \
  && mecab --version
# [5/6][mecab-ko-dic] unzipping
RUN ls -al && tar -zxvf mecab-ko-dic-2.1.1-20180720.tar.gz
# [5/6][mecab-ko-dic] build and install
RUN cd mecab-ko-dic-2.1.1-20180720 \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install

RUN echo '#!/bin/bash\n\
  cd /app/mecab-ko-dic-2.1.1-20180720 \\\n\
    && tools/add-userdic.sh \\\n\
    && make install' > /app/compile-dic.sh && chmod +x /app/compile-dic.sh
VOLUME /app
VOLUME /usr/local/lib/mecab/dic/mecab-ko-dic
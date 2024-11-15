FROM ubuntu:latest

WORKDIR /app
# [1/6] installing build tools
RUN apt-get update && \
  apt-get install -y wget nano build-essential automake libtool
# [2/6][mecab-ko] downloading
RUN wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz \
  && tar xvfz mecab-0.996-ko-0.9.2.tar.gz
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
# [5/6][mecab-ko-dic] downloading
RUN wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz
RUN ls -al && tar -zxvf mecab-ko-dic-2.1.1-20180720.tar.gz
# [5/6][mecab-ko-dic] build and install
RUN cd mecab-ko-dic-2.1.1-20180720 \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install
VOLUME /app
VOLUME /usr/local/lib/mecab/dic/mecab-ko-dic
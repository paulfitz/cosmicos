# This creates an image that is good enough for building CosmicOS

FROM ubuntu:18.04

# enough for main message
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends libbcel-java openjdk-8-jdk libgd-perl \
    haxe cmake make && \
  rm -rf /var/lib/apt/lists/*

RUN \
  apt-get update && \
  apt-get install -y curl && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

# lots of stuff needed for node canvas for old spider script
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends libcairo2-dev libjpeg-dev libpango1.0-dev \
    libgif-dev build-essential g++ && \
  rm -rf /var/lib/apt/lists/*

ENV NODE_PATH=/usr/local/lib/node_modules:/usr/log/node_modules

RUN mkdir /tmp/.npm-global
ENV PATH=/tmp/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/tmp/.npm-global

# I promise I'll start using package.json one day
RUN npm install canvas -g --unsafe

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends imagemagick potrace fontforge-nox && \
  rm -rf /var/lib/apt/lists/*

# oh my word, looks like I used a ruby gem to make font files for the spider font
# and eek that fontcustom gem needs some unpackaged woff stuff
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends ruby ruby-dev git && \
  gem install fontcustom --no-ri --no-rdoc && \
  rm -rf /var/lib/apt/lists/* && \
  git clone https://github.com/bramstein/sfnt2woff-zopfli.git sfnt2woff-zopfli && cd sfnt2woff-zopfli && make && mv sfnt2woff-zopfli /usr/local/bin/sfnt2woff && cd .. && \
  git clone --recursive https://github.com/google/woff2.git && cd woff2 && make clean all && mv woff2_compress /usr/local/bin/ && mv woff2_decompress /usr/local/bin/ && cd .. && \
  rm -rf sfnt2woff-zopfli woff2

# handy to be able to edit configuration options
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends cmake-curses-gui && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /cosmicos

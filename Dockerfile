FROM elixir:1.4.2-slim
LABEL maintainer="hattori045"

ENV TZ Asia/Tokyo

# RUN rm /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EF0F382A1A7B6500
RUN set -x && \
  apt-get update && \
  apt-get install -y \
  curl && \
  curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
  apt-get install -y --no-install-recommends \
  nodejs \
  build-essential \
  mysql-client \
  inotify-tools \
  git \
  make \
  imagemagick \
  tar \
  ssh \
  gzip \
  g++ \
  vim \
  ca-certificates && \
  apt-get install -y --no-install-recommends \
  npm && \
  rm -rf /var/lib/apt/lists/* && \
  npm cache clean --force && \
  npm install n -g && \
  n stable && \
  ln -sf /usr/local/bin/node /usr/bin/node && \
  apt-get purge -y nodejs npm

#install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    apt-get update

#set timezone
RUN echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

#install awscli
RUN apt-get update && apt-get install -y python2.7-dev python-setuptools && easy_install pip && pip install awscli

# Add erlang-history
RUN git clone -q https://github.com/ferd/erlang-history.git && \
    cd erlang-history && \
    make install && \
    cd - && \
    rm -fR erlang-history

# Add local node module binaries to PATH
ENV PATH $PATH:node_modules/.bin:/opt/elixir-1.4.5/bin

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

EXPOSE 4000

CMD ["sh", "-c", "mix deps.get && elixir --sname vitalgear-node --cookie vitalgear -S mix phoenix.server"]

FROM elixir:1.5.3-slim
LABEL maintainer="hattori045"

ENV TZ Asia/Tokyo

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  curl && \
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
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
  rm -rf /var/lib/apt/lists/* && \
  # npm cache clean --force && \
  # npm install n -g && \
  # n stable && \
  ln -sf /usr/local/bin/node /usr/bin/node
  # ln -sf /usr/local/bin/node /usr/bin/node && \
  # apt-get purge -y nodejs npm

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
ENV PATH $PATH:node_modules/.bin:/opt/elixir-1.5.3/bin

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

EXPOSE 4000

CMD ["sh", "-c", "mix deps.get && mix ecto.migrate && elixir --sname vitalgear-node --cookie vitalgear -S mix phx.server"]

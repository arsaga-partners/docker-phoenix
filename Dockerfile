FROM elixir:1.4.2-slim
MAINTAINER homi

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  nodejs \
  npm \
  mysql-client \
  inotify-tools \
  git \
  make \
  imagemagick \
  tar \
  ssh \
  gzip \
  g++ \
  ca-certificates \
  curl && \
  rm -rf /var/lib/apt/lists/*

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

EXPOSE 4002

CMD ["sh", "-c", "mix deps.get && mix phoenix.server"]

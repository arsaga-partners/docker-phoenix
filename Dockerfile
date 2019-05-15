FROM elixir:1.5.3-slim
LABEL maintainer="hattori045"

ENV TZ Asia/Tokyo

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  curl && \
  curl -sL https://deb.nodesource.com/10.x | bash - && \
  apt-get install -y --no-install-recommends \
  nodejs \
  mysql-client \
  inotify-tools \
  git \
  make \
  imagemagick \
  tar \
  ssh \
  vim \
  gzip \
  cron \
  g++ \
  ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# Add erlang-history
RUN git clone -q https://github.com/ferd/erlang-history.git && \
    cd erlang-history && \
    make install && \
    cd - && \
    rm -fR erlang-history

#set timezone
RUN echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Add local node module binaries to PATH
ENV PATH $PATH:node_modules/.bin:/opt/elixir-1.7.4/bin

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

EXPOSE 4002

CMD ["sh", "-c", "mix deps.get && elixir --sname vitalgear-node --cookie vitalgear -S mix phoenix.server"]

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
  mysql-client \
  inotify-tools \
  git \
  make \
  vim \
  imagemagick \
  tar \
  ssh \
  gzip \
  g++ \
  ca-certificates \
  python2.7-dev \
  python-setuptools \
  sqlite3 \
  locales \
  sudo \
  software-properties-common \
  wget \
  gnupg && \
  rm -rf /var/lib/apt/lists/* && \
  easy_install pip && \
  pip install awscli

#set timezone
RUN echo "${TZ}" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Add erlang-history
RUN git clone -q https://github.com/ferd/erlang-history.git && \
    cd erlang-history && \
    make install && \
    cd - && \
    rm -fR erlang-history

# Add local node module binaries to PATH
ENV PATH $PATH:node_modules/.bin:/opt/elixir-1.7.4/bin

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

# Set Locale
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

RUN curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" | sudo apt-key add
RUN sudo echo "deb http://download.mono-project.com/repo/debian stretch main" | tee /etc/apt/sources.list.d/mono-official.list
RUN sudo apt-get update
RUN sudo apt-get install -y mono-devel

EXPOSE 4000

CMD ["sh", "-c", "mix deps.get && elixir --sname vitalgear-node --cookie vitalgear -S mix phoenix.server"]

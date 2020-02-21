#------------------------------
# Build image
#------------------------------
FROM elixir:1.9-alpine AS build
LABEL maintainer="Alessandro Iob <alessandro.iob@gmail.com>"

ARG APP_NAME=flashfeed

# RUN apk add tzdata && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN apk update && \
    apk add --update git build-base nodejs yarn python inotify-tools && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.4.13

WORKDIR /srv/flashfeed

COPY mix.exs mix.lock ./
COPY config config

# Environment setting
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    REPLACE_OS_VARS=true \
    TERM=xterm

RUN mix deps.get && \
    MIX_ENV=dev mix deps.compile && \
    MIX_ENV=test mix deps.compile && \
    mix deps.compile

# Application files
COPY . .

# Fetch the application dependencies and build the application

RUN mix format --check-formatted && \
    mix compile --force --warnings-as-errors && \
    MIX_ENV=test mix test --exclude integration && \
    yarn --cwd=./assets --non-interactive install && \
    yarn --cwd=./assets --prod run deploy && \
    mix phx.digest && \
    mix release --overwrite

#------------------------------
# Release image
#------------------------------
FROM alpine:3.9 as release

RUN apk update && \
    apk add --no-cache --update bash openssl ncurses-libs

WORKDIR /srv/flashfeed

COPY --from=build /srv/flashfeed/_build/prod/rel/flashfeed ./
RUN chown -R nobody: .
USER nobody

ENV LANG=C.UTF-8 \
    REPLACE_OS_VARS=true \
    FLASHFEED_ENDPOINT_PORT=41384 \
    HOME=/srv/flashfeed

EXPOSE $FLASHFEED_ENDPOINT_PORT

CMD ["bin/flashfeed", "start"]

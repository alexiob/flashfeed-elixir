#------------------------------
# Build image
#------------------------------
FROM elixir:1.9-alpine AS build
LABEL maintainer="Alessandro Iob <alessandro.iob@gmail.com>"

# RUN apk add tzdata && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime

ARG APP_NAME=flashfeed

RUN apk update && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.4.9

WORKDIR /srv/flashfeed

COPY mix.exs mix.lock ./

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
    mix phx.digest && \
    mix release --overwrite

#------------------------------
# Release image
#------------------------------
FROM alpine:3.9 as release

RUN apk update && \
    apk --no-cache --update add bash openssl ncurses-libs

WORKDIR /srv/flashfeed

RUN adduser -D -g 'flashfeed' flashfeed

COPY --from=build /srv/flashfeed/_build/prod ./_build/prod
RUN chown -R flashfeed: .
USER flashfeed

ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    REPLACE_OS_VARS=true \
    PORT=41384

EXPOSE $PORT

# CMD ["./_build/prod/rel/flashfeed/bin/flashfeed", "start"]
CMD ["bash"]

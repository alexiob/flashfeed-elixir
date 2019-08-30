# Flashfeed (Elixir version)

Local radio news feed for Alexa, build with Elixir

## Local Build

```sh
docker build -t flashfeed-elixir:latest .
```

## Local Start

Elixir

```sh
mix run --no-halt
```

Docker:

```sh
docker stop flashfeed-elixir
docker run --name flashfeed-elixir --rm -p 41384:41384 -t flashfeed-elixir:latest
```

## Start

## Deploy

## Endpoint Test

Local:

```sh
curl -X GET https://localhost:41384/v1/api/alexa/flashfeed/rainews/rainews/it/fvg/gr
```

Deployment:

```sh
curl -X GET https://flashfeed.iob.toys/v1/api/alexa/flashfeed/rainews/rainews/it/fvg/gr
```

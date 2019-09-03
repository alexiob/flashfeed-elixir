# Flashfeed (Elixir version)

Local radio news feed for Amazon (and friends, eventually), build with Elixir

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
curl -X GET https://localhost:41384/api/v1/amazon_alexa/rainews/rainews/it/fvg/gr
```

Deployment:

```sh
curl -X GET https://flashfeed.iob.toys/api/v1/amazon_alexa/rainews/rainews/it/fvg/gr
```

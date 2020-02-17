# Flashfeed (Elixir version)

Local radio and video news feed for Amazon (and friends, eventually), build with Elixir.

Exercises:

- [Elixir](https://elixir-lang.org/) language
- [Phoenix Framework](https://www.phoenixframework.org/) as API server and CORS proxy
- [Phenix LiveView](https://github.com/phoenixframework/phoenix_live_view) for UI with live search and media playback
- [Pow](https://github.com/danschultzer/pow) for user authentication, integrated with LiveView
- [Floki](https://github.com/philss/floki) HTML parser for web scraping
- [News feed generation](https://developer.amazon.com/en-US/docs/alexa/flashbriefing/understand-the-flash-briefing-skill-api.html) for Amazon Alexa
- Docker with Multi-stage build
- [Phoenix Swagger](https://github.com/xerions/phoenix_swagger) for API documentation

![Flashfeed UI](/docs/images/ui_example.png?raw=true "Flashfeed UI")

## Local Build

```sh
mix deps.get
mix phx.swagger.generate
```

Note: when LiveView version is updated we need to update the assets as well

```sh
cd assets
npm install phoenix_live_view --force
```

## Local Docker Build

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
curl -X GET http://localhost:41384/api/v1/feed/amazon_alexa/rainews/rainews/it/fvg/gr
```

Deployment:

```sh
curl -X GET https://flashfeed.iob.toys/api/v1/feed/amazon_alexa/rainews/rainews/it/fvg/gr
```

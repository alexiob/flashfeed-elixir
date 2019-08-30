defmodule Flashfeed.MixProject do
  use Mix.Project

  def project do
    [
      app: :flashfeed,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() != :test do
      [
        mod: {Flashfeed.Application, []},
        extra_applications: [:logger, :timex, :runtime_tools]
      ]
    else
      [
        extra_applications: [:logger]
      ]
    end
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    Local radio news feed for Alexa.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Alessandro Iob"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alexiob/flashfeed-elixir"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:ecto, "~> 3.1.7"},
      {:httpoison, "~> 1.5.1"},
      {:floki, "~> 0.22.0"},
      {:timex, "~> 3.6.1"},
      {:plug_cowboy, "~> 2.1"},
      {:observer_cli, "~> 1.5"},
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: [:dev]},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end

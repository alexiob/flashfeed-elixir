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
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() != :test do
      [
        mod: {Flashfeed.Application, []},
        extra_applications: [:logger, :timex]
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
    Local Radio news feed for Alexa.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Alessandro Iob"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alexiob/flashfeed-elixir"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.1.7"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.5.1"},
      {:floki, "~> 0.22.0"},
      {:timex, "~> 3.6.1"},
      {:plug_cowboy, "~> 2.1"},
      {:phoenix, "~> 1.4"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2"}
    ]
  end
end

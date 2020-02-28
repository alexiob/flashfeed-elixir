defmodule Flashfeed.MixProject do
  use Mix.Project

  def project do
    [
      app: :flashfeed,
      version: "0.3.0",
      elixir: "~> 1.9",
      description: description(),
      dialyzer: dialyzer(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:phoenix_swagger],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() != :test do
      [
        mod: {Flashfeed.Application, []},
        extra_applications: [:logger, :timex, :runtime_tools, :absinthe_plug],
        included_applications: [:mnesia]
      ]
    else
      [
        extra_applications: [:logger, :absinthe_plug],
        included_applications: [:mnesia]
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
      {:jason, "~> 1.1.2"},
      {:ecto, "~> 3.3.4"},
      {:ecto_sql, "~> 3.3.4"},
      {:postgrex, "~> 0.15.3"},
      {:httpoison, "~> 1.6.2"},
      {:floki, "~> 0.25.0"},
      {:timex, "~> 3.6.1"},
      {:plug_cowboy, "~> 2.1.2"},
      {:plug, "~> 1.8.3"},
      {:cors_plug, "~> 2.0.2"},
      {:exconstructor, "~> 1.1.0"},
      {:spellbook, "~> 2.0.3"},
      {:observer_cli, "~> 1.5.3"},
      {:absinthe, "~> 1.4.0"},
      {:absinthe_plug, "~> 1.4.0"},
      {:absinthe_phoenix, "~> 1.4.0"},
      {:phoenix, "~> 1.4.14"},
      {:phoenix_pubsub, "~> 1.1.2"},
      {:phoenix_ecto, "~> 4.1.0"},
      {:phoenix_html, "~> 2.14.0", override: true},
      {:phoenix_live_view, "~> 0.8.1"},
      {:phoenix_live_reload, "~> 1.2.1", only: [:dev]},
      {:phoenix_swagger, "~> 0.8.2"},
      {:pow, "~> 1.0.18"},
      {:gettext, "~> 0.17.4"},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:credo, "~> 1.2.2", only: [:dev, :test], runtime: false}
      # {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      # {:excoveralls, "~> 0.9", only: [:dev]},
      # {:eye_drops, "~> 1.3", only: [:dev], runtime: false},
      # {:inch_ex, "~> 2.0", only: [:dev], runtime: false},
      # {:stream_data, "~> 0.4", only: [:dev]}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      # test: ["ecto.create --quiet", "ecto.migrate", "test"]
      test: ["test"]
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: "dialyzer.ignore-warnings",
      plt_add_apps: [:mix],
      plt_core_path: "_build",
      remove_defaults: [:unknown]
    ]
  end
end

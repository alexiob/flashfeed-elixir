defmodule Flashfeed.News.Sources do
  @moduledoc false

  require Logger

  @spec load :: [Flashfeed.News.Entity.t()] | {:error, atom}
  def load() do
    filename =
      Path.join([
        Application.app_dir(:flashfeed),
        Application.get_env(:flashfeed, :crawler_news_outlets_config_path)
      ])

    Logger.debug("Flashfeed.News.Source.load: loading '#{filename}'...")

    config = load_config(filename, :spellbook)
    json_data_to_entities_list(config["outlets"])
  end

  defp load_config(filename, :spellbook) do
    Spellbook.default_config()
    |> Spellbook.load_config(
      folder: Path.dirname(filename),
      config_filename: Path.basename(filename, Path.extname(filename))
    )
  end

  defp load_config(filename, :json) do
    with {:ok, json_data} <- File.read(filename),
         {:ok, data} <- Jason.decode(json_data) do
      data
    else
      {:error, reason} ->
        Logger.error("Flashfeed.News.Source.load: error loading '#{filename}': #{reason}")
        {:error, reason}
    end
  end

  defp json_data_to_entities_list(data) do
    for news_outlet <- data,
        %{"enabled" => true} = news_source <- Map.get(news_outlet, "news_sources", []),
        into: [] do
      news_source
      |> Map.merge(%{
        "uuid" => "#{Ecto.UUID.generate()}",
        "country" => news_outlet["country"],
        "outlet_name" => news_outlet["name"],
        "outlet_title" => news_outlet["title"],
        "outlet_url" => news_outlet["url"]
      })
      |> Flashfeed.News.Entity.new()
    end
  end
end

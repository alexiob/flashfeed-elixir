defmodule Flashfeed.News.Sources do
  @moduledoc false

  require Logger

  @spec load :: [any] | {:error, atom}
  def load() do
    filename =
      Path.join([
        Application.app_dir(:flashfeed),
        Application.get_env(:flashfeed, :crawler_news_outlets_config_path)
      ])

    Logger.debug("Flashfeed.News.Source.load: loading '#{filename}'...")

    with {:ok, json_data} <- File.read(filename),
         {:ok, data} <- Jason.decode(json_data) do
      json_data_to_entities_list(data)
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
    end
  end
end

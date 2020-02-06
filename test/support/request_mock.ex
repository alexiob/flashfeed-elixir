defmodule Flashfeed.News.Crawler.Request.Mock do
  @moduledoc false

  @url_news_source_prefix ~r/^https\:\/\/www\.rainews\.it\/tgr\/([[:alnum:]])+\/notiziari\//ui
  @url_news_feed_prefix ~r/^https\:\/\/www\.rainews\.it\/dl\/rai24\/tgr\/basic\/archivio\//ui

  @file_path "./test/data/"
  @file_news_source @file_path <> "rainews-it-source.html"

  def proxy(_conn, _url) do
    # not implemented
  end

  def get(url, decode_json) do
    cond do
      Regex.match?(@url_news_source_prefix, url) -> news_source(url, decode_json)
      Regex.match?(@url_news_feed_prefix, url) -> news_feed(url, decode_json)
      true -> {:error, "Url not matched: #{url}"}
    end
  end

  defp news_source(_url, decode_json) do
    {:ok, load_file(@file_news_source, decode_json)}
  end

  defp news_feed(url, decode_json) do
    {:ok,
     Path.join([@file_path, Path.basename(URI.parse(url).path)])
     |> load_file(decode_json)}
  end

  defp load_file(filename, decode_json) do
    {:ok, file} = File.open(filename, [:read])
    data = IO.read(file, :all)
    File.close(file)

    case decode_json do
      true ->
        {:ok, decoded_data} = Jason.decode(data)
        decoded_data

      false ->
        data
    end
  end
end

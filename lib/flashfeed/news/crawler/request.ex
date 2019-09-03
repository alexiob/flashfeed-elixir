defmodule Flashfeed.News.Crawler.Request do
  @moduledoc """
  Abstracts all HTTP client specific interactions.
  During tests it is replaced with Flashfeed.News.Crawler.Request.Mock
  """

  def get(url, decode_json) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case decode_json === true do
          true -> body |> Jason.decode()
          false -> {:ok, body}
        end

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Content Not found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

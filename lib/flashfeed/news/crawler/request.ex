defmodule Flashfeed.News.Crawler.Request do
  @moduledoc """
  Abstracts all HTTP client specific interactions.
  During tests it is replaced with Flashfeed.News.Crawler.Request.Mock
  """
  require Logger
  import Plug.Conn

  @http_options [ssl: [{:versions, [:"tlsv1.2"]}]]

  def proxy(conn, url) when is_list(url) do
    [protocol | path] = url
    proxy(conn, "#{protocol}//#{Enum.join(path, "/")}")
  end

  def proxy(conn, url) do
    full_url = "#{url}?#{conn.query_string}"

    process_proxy_url(conn, full_url)
  end

  defp process_proxy_url(conn, url) do
    case HTTPoison.get(url, [], @http_options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers} = _response} ->
        {"Content-Type", content_type} = List.keyfind(headers, "Content-Type", 0)

        conn
        |> put_resp_content_type(content_type)
        |> put_resp_header("access-control-allow-origin", "*")
        |> send_resp(200, body)

      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        {"Location", new_url} = List.keyfind(headers, "Location", 0)

        Logger.debug(
          "Flashfeed.News.Crawler.Request.proxy: redirecting from #{url} to #{new_url}"
        )

        process_proxy_url(conn, new_url)

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(:bad_gateway)
        |> send_resp(404, reason)
    end
  end

  def get(url, decode_json) do
    case HTTPoison.get(url, [], @http_options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case decode_json === true do
          true -> body |> Jason.decode()
          false -> {:ok, body}
        end

      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        # moved permanently
        {"Location", new_url} = List.keyfind(headers, "Location", 0)
        Logger.debug("Flashfeed.News.Crawler.Request.get: redirecting from #{url} to #{new_url}")
        get(new_url, decode_json)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Content Not found"}

      {:ok, response = %HTTPoison.Response{}} ->
        {:error, "Unsupported response: #{inspect(response)}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end

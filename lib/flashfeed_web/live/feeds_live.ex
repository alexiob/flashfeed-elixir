defmodule FlashfeedWeb.FeedsLive do
  @moduledoc false
  use Phoenix.LiveView
  alias Flashfeed.News.Crawler
  alias FlashfeedWeb.Router.Helpers, as: Routes

  require Logger

  def render(assigns) do
    Logger.debug("Flashfeed.FeedsLive.render[#{inspect(self())}]")
    Phoenix.View.render(FlashfeedWeb.FeedsLiveView, "feeds_live.html", assigns)
  end

  def mount(_params, %{"current_user" => current_user} = _session, socket) do
    Logger.debug(
      "Flashfeed.FeedsLive.mount[#{inspect(self())}]: #{inspect(get_connect_info(socket))}"
    )

    Crawler.subscribe()
    FlashfeedWeb.UserAuthenticationCallbacks.subscribe(current_user.id)

    user_data = get_user_data_cache(current_user.id)

    {
      :ok,
      assign(
        socket,
        current_user: current_user,
        query: user_data.query,
        loading: false,
        entity_feeds_last_update: Crawler.entity_feeds_last_update(),
        entity_feeds: filtered_entity_feeds(user_data.query),
        active_source: new_active_source("just click on an entry", nil, nil, "Select source...")
      )
    }
  end

  defp get_user_data_cache(user_id) do
    case Cachex.get(:user_data_cache, {__MODULE__, user_id}) do
      {:ok, nil} -> %{query: nil}
      {:ok, data} -> data
    end
  end

  def update_user_data_cache(user_id, data) do
    Cachex.put(
      :user_data_cache,
      {__MODULE__, user_id},
      Map.merge(get_user_data_cache(user_id), data)
    )
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    update_user_data_cache(socket.assigns.current_user.id, %{query: query})

    {:noreply, assign(socket, query: query, entity_feeds: filtered_entity_feeds(query))}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    send(self(), {:search, query})

    {:noreply, assign(socket, query: query, loading: true, entity_feeds: [])}
  end

  def handle_event(
        "play",
        %{
          "source_title" => title,
          "source_date" => date,
          "source_url" => url,
          "source_media_type" => media_type
        },
        socket
      ) do
    {:noreply,
     assign(socket,
       active_source: new_active_source(title, url, media_type, date)
     )}
  end

  def handle_info({:search, query}, socket) do
    update_user_data_cache(socket.assigns.current_user.id, %{query: query})

    {:noreply, assign(socket, loading: false, entity_feeds: filtered_entity_feeds(query))}
  end

  def handle_info(%{event: :feeds_update}, socket) do
    # Logger.debug("Flashfeed.FeedsLive.handle_info[#{inspect(self())}]: :feeds_update")
    Logger.debug(
      "Flashfeed.FeedsLive.handle_info[#{inspect(self())}]: :feeds_update query='#{
        socket.assigns.query
      }' #{inspect(filtered_entity_feeds(socket.assigns.query), pretty: true)}"
    )

    {:noreply,
     assign(socket,
       entity_feeds_last_update: Crawler.entity_feeds_last_update(),
       entity_feeds: filtered_entity_feeds(socket.assigns.query)
     )}
  end

  # NOTE: this is not going to happen as we are doing login from a NOT-LiveView and so, no mount
  def handle_info(%{event: :auth_login, current_user: current_user}, socket) do
    {:noreply, assign(socket, current_user: current_user)}
  end

  def handle_info(%{event: :auth_logout, current_user: _current_user}, socket) do
    socket =
      socket
      |> assign(current_user: nil)
      |> redirect(to: Routes.pow_session_path(socket, :new))

    {:noreply, socket}
  end

  defp new_active_source(title, url, "video" = media_type, date) do
    proxy_url =
      case url do
        nil -> url
        "" -> url
        _ -> "/api/v1/proxy/#{url}"
      end

    new_active_source_map(title, proxy_url, media_type, date)
  end

  defp new_active_source(title, url, media_type, date) do
    new_active_source_map(title, url, media_type, date)
  end

  defp new_active_source_map(title, url, media_type, date) do
    %{
      title: title,
      url: url,
      media_type: media_type,
      type: media_type_to_html_type(media_type),
      date: date
    }
  end

  defp media_type_to_html_type(media_type) do
    case media_type do
      "audio" -> "audio/playlist"
      "video" -> "video"
      _ -> media_type
    end
  end

  defp filtered_entity_feeds do
    filtered_entity_feeds("")
  end

  defp filtered_entity_feeds(nil) do
    filtered_entity_feeds("")
  end

  defp filtered_entity_feeds(query) when is_binary(query) do
    supported_media_types = Application.get_env(:flashfeed, :supported_media_types)

    parsed_query =
      query
      |> String.trim()
      |> String.downcase()
      |> String.split()

    Map.values(Crawler.entity_feeds())
    |> Enum.filter(fn entity_feed ->
      text = String.downcase(entity_feed.title_text)

      Enum.find(supported_media_types, fn t -> t == entity_feed.media_type end) &&
        Enum.all?(parsed_query, &String.contains?(text, &1))
    end)
    |> Enum.sort_by(&{&1.date, &1.title_text})
    |> Enum.map(fn entity_feed ->
      icon =
        case entity_feed.media_type do
          "video" -> "fa-video"
          "audio" -> "fa-podcast"
        end

      Map.put(entity_feed, :icon, icon)
    end)
  end
end

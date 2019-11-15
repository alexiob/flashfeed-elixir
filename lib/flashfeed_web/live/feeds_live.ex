defmodule FlashfeedWeb.FeedsLive do
  use Phoenix.LiveView

  require Logger

  import Phoenix.HTML

  def render(assigns) do
    ~L"""
    <audio controls <%= if @active_source.media_type != "audio", do: "hidden" %> src="<%= raw(@active_source.url) %>" type="<%= @active_source.type %>">
    </audio>

    <form phx-change="suggest" phx-submit="search" phx-throttle="300">
      <input class="ff-search" type="text" name="q" value="<%= @query %>" autocomplete="off" placeholder="search..." <%= if @loading, do: "readonly" %>/>
      <ul>
        <%= for entity_feed <- @entity_feeds do %>
          <li phx-click="play" phx-value-source_url="<%= entity_feed.url %>" phx-value-source_media_type="<%= entity_feed.media_type %>"><%= entity_feed.title_text %> del <%= Timex.format!(entity_feed.date, "{D}-{M}-{YYYY}") %></li>
        <% end %>
      </ul>
    </form>
    """
  end

  def mount(_session, socket) do
    entity_feeds = filtered_entity_feeds()

    {:ok,
     assign(socket,
       query: nil,
       loading: false,
       entity_feeds: entity_feeds,
       active_source: new_active_source(nil, nil)
     )}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    entity_feeds = filtered_entity_feeds(query)

    {:noreply, assign(socket, entity_feeds: entity_feeds)}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    # FIXME: review
    send(self(), {:search, query})

    {:noreply, assign(socket, query: query, loading: true, entity_feeds: [])}
  end

  def handle_info({:search, query}, socket) do
    entity_feeds = filtered_entity_feeds(query)

    {:noreply, assign(socket, loading: false, entity_feeds: entity_feeds)}
  end

  def handle_event("play", %{"source_url" => url, "source_media_type" => media_type}, socket) do
    active_source = new_active_source(url, media_type)

    {:noreply,
     assign(socket,
       active_source: active_source
     )}
  end

  defp new_active_source(url, media_type) do
    %{
      url: url,
      media_type: media_type,
      type: "audio/playlist"
    }
  end

  defp filtered_entity_feeds() do
    filtered_entity_feeds("")
  end

  defp filtered_entity_feeds(query) when is_binary(query) do
    supported_media_types = Application.get_env(:flashfeed, :supported_media_types)

    parsed_query =
      query
      |> String.trim()
      |> String.downcase()
      |> String.split()

    Map.values(Flashfeed.News.Crawler.entity_feeds())
    |> Enum.filter(fn entity_feed ->
      text = String.downcase(entity_feed.title_text)

      Enum.find(supported_media_types, fn t -> t == entity_feed.media_type end) &&
        Enum.all?(parsed_query, &String.contains?(text, &1))
    end)
  end
end

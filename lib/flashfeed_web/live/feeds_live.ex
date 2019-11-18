defmodule FlashfeedWeb.FeedsLive do
  use Phoenix.LiveView

  require Logger

  import Phoenix.HTML

  def render(assigns) do
    ~L"""
    <div class="ff-player-title-date"><%= @active_source.date %></div>
    <div class="ff-player-title"><%= @active_source.title %></div>
    <div class="ff-player" <%= if @active_source.media_type != "audio", do: "hidden" %>>
      <div  class="ff-player-control">
        <audio controls type="<%= @active_source.type %>" src="<%= raw(@active_source.url) %>">
        </audio>
      </div>
    </div>

    <form phx-change="suggest" phx-submit="search" phx-throttle="300">
      <input class="ff-search" type="text" name="q" value="<%= @query %>" autocomplete="off" placeholder="search..." <%= if @loading, do: "readonly" %>/>
      <ul class="fa-ul">
        <%= for entity_feed <- @entity_feeds do %>
          <li class="ff-entity-feed" phx-click="play" phx-value-source_title="<%= entity_feed.title_text %>" phx-value-source_date="<%= Timex.format!(entity_feed.date, "{0D}/{0M}/{YYYY}") %>" phx-value-source_url="<%= entity_feed.url %>" phx-value-source_media_type="<%= entity_feed.media_type %>">
            <span class="fa-li"><i class="fas fa-podcast"></i></span>
            [<%= Timex.format!(entity_feed.date, "{0D}/{0M}/{YYYY}") %>] <%= entity_feed.title_text %>
          </li>
        <% end %>
      </ul>
    </form>
    """
  end

  def mount(_session, socket) do
    Flashfeed.News.Crawler.subscribe()

    {:ok,
     assign(socket,
       query: nil,
       loading: false,
       entity_feeds: filtered_entity_feeds(),
       active_source: new_active_source("just click on an entry", nil, nil, "Select source...")
     )}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    {:noreply, assign(socket, entity_feeds: filtered_entity_feeds(query))}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    # FIXME: review
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
    {:noreply, assign(socket, loading: false, entity_feeds: filtered_entity_feeds(query))}
  end

  def handle_info(%{event: :update} = broadcast, socket) do
    Logger.debug(">>> Broadcast: #{inspect(broadcast)}")
    Logger.debug(">>> socket: #{inspect(socket)}")

    {:noreply, assign(socket, entity_feeds: filtered_entity_feeds(socket.assigns.query))}
  end

  defp new_active_source(title, url, media_type, date) do
    %{
      title: title,
      url: url,
      media_type: media_type,
      type: "audio/playlist",
      date: date
    }
  end

  defp filtered_entity_feeds() do
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

    Map.values(Flashfeed.News.Crawler.entity_feeds())
    |> Enum.filter(fn entity_feed ->
      text = String.downcase(entity_feed.title_text)

      Enum.find(supported_media_types, fn t -> t == entity_feed.media_type end) &&
        Enum.all?(parsed_query, &String.contains?(text, &1))
    end)
  end
end

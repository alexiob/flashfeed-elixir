defmodule FlashfeedWeb.FeedsLive do
  use Phoenix.LiveView

  require Logger

  def render(assigns) do
    ~L"""
    <form phx-change="suggest" phx-submit="search">
      <input class="ff-search" type="text" name="q" value="<%= @query %>" list="matches" placeholder="search..."
            <%= if @loading, do: "readonly" %>/>
      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value="<%= match %>"><%= match %></option>
        <% end %>
      </datalist>
      <%=if @result do %><pre class="ff-results"><%= @result %></pre><% end %>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, query: nil, result: nil, loading: false, matches: [])}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    {words, _} = System.cmd("grep", ~w"^#{query}.* -m 5 /usr/share/dict/words")
    {:noreply, assign(socket, match: String.split(words, "\n"))}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    Logger.debug("Query: #{inspect(query)}")
    send(self(), {:search, query})
    {:noreply, assign(socket, query: query, result: "Searching...", loading: true, matches: [])}
  end

  def handle_info({:search, query}, socket) do
    {result, _} = System.cmd("dict", ["#{query}"], stderr_to_stdout: true)
    {:noreply, assign(socket, loading: false, result: result, matches: [])}
  end
end

defmodule FlashfeedWeb.UserAuthenticationCallbacks do
  @moduledoc false
  alias Pow.Extension.Phoenix.ControllerCallbacks

  require Logger

  def subscribe(user_id) do
    # Logger.debug(">>> SUBSCRIBE[#{user_topic(user_id)}]")
    Phoenix.PubSub.subscribe(Flashfeed.PubSub, user_topic(user_id))
  end

  defp notify(event, current_user) do
    # Logger.debug(">>> NOTIFY[#{user_topic(current_user.id)}]: #{event} -> #{inspect(current_user)}")
    Phoenix.PubSub.broadcast(
      Flashfeed.PubSub,
      user_topic(current_user.id),
      %{event: event, current_user: current_user}
    )
  end

  defp user_topic(user_id) do
    "auth/user/#{user_id}"
  end

  # @impl true
  def before_respond(Pow.Phoenix.SessionController, action, {:ok, conn}, config)
      when action in [:new, :create] do
    current_user = Pow.Plug.current_user(conn)

    notify(:auth_login, current_user)

    ControllerCallbacks.before_respond(Pow.Phoenix.SessionController, action, {:ok, conn}, config)
  end

  # @impl true
  def before_process(Pow.Phoenix.SessionController, :delete, conn, config) do
    current_user = Pow.Plug.current_user(conn)

    notify(:auth_logout, current_user)

    ControllerCallbacks.before_process(Pow.Phoenix.SessionController, :delete, conn, config)
  end

  defdelegate before_respond(controller, action, results, config), to: ControllerCallbacks

  defdelegate before_process(controller, action, results, config), to: ControllerCallbacks
end

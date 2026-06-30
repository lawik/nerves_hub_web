defmodule NervesHubWeb.RateLimitPubSub do
  use GenServer

  alias NervesHubWeb.Plugs.Attack

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def broadcast(key, time) do
    server = GenServer.whereis(__MODULE__)
    Phoenix.PubSub.broadcast_from!(NervesHub.PubSub, server, "ratelimit", {:throttle, key, time})
  end

  def init([]) do
    _ = Phoenix.PubSub.subscribe(NervesHub.PubSub, "ratelimit")
    {:ok, []}
  end

  def handle_info({:throttle, {:cli_session_token, token}, time}, state) do
    _ = Attack.token_throttle(token, time: time)
    {:noreply, state}
  end

  def handle_info({:throttle, :cli_session_global, time}, state) do
    _ = Attack.global_throttle(time: time)
    {:noreply, state}
  end

  # Ignore unrecognised keys (e.g. messages from an older node during a rolling
  # deploy) rather than crashing the throttle-sync process.
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

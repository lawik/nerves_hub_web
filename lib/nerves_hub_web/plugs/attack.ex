defmodule NervesHubWeb.Plugs.Attack do
  use PlugAttack

  alias NervesHub.PlugAttack.Storage
  alias NervesHubWeb.RateLimitPubSub
  alias PlugAttack.Storage.Ets

  # Guards the unauthenticated CLI-session poll endpoint
  # (GET /api/auth/cli_session/:token).
  #
  # The throttle is keyed on the session token, not the client IP. The token is
  # the secret being polled, so per-token keying directly bounds how fast a
  # session can be polled; it cannot be evaded by spoofing X-Forwarded-For and
  # does not depend on resolving the real client IP behind a proxy/CDN/NAT. A
  # coarse global limit backstops raw request floods (including sweeps across
  # many different tokens, which each get their own per-token bucket).
  @token_limit 30
  @token_period :timer.minutes(1)
  @global_limit 1_000
  @global_period :timer.minutes(1)

  rule "throttle cli session polling", conn do
    # Evaluate both buckets (so each is counted), then block if either is over.
    token_block = token_throttle(conn.path_params["token"])
    global_block = global_throttle()
    token_block || global_block
  end

  @doc false
  def token_throttle(token, opts \\ []) do
    throttle({:cli_session_token, token}, @token_limit, @token_period, opts)
  end

  @doc false
  def global_throttle(opts \\ []) do
    throttle(:cli_session_global, @global_limit, @global_period, opts)
  end

  defp throttle(key, limit, period, opts) do
    time = opts[:time] || System.system_time(:millisecond)
    if !opts[:time], do: RateLimitPubSub.broadcast(key, time)

    expires_at = expires_at(time, period)
    count = Ets.increment(Storage, {:throttle, key, div(time, period)}, 1, expires_at)

    if count > limit do
      {:block, {:throttle, limit: limit, period: period, expires_at: expires_at, remaining: 0}}
    end
  end

  defp expires_at(now, period), do: (div(now, period) + 1) * period
end

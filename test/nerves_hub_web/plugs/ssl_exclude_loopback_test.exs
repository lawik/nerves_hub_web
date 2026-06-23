defmodule NervesHubWeb.Plugs.SSLExcludeLoopbackTest do
  use ExUnit.Case, async: true

  import Plug.Test
  import Plug.Conn

  # These are the exact options used by the production SSL plug in
  # lib/nerves_hub_web/endpoint.ex:
  #
  #   plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], exclude: ["localhost"])
  #
  # Passing exclude: ["localhost"] overrides Plug.SSL's default exclude of
  # [hosts: ["localhost", "127.0.0.1"]], which means the 127.0.0.1 loopback
  # address is no longer excluded and a plain-HTTP request to it gets
  # redirected to https.
  @ssl_opts [rewrite_on: [:x_forwarded_proto], exclude: ["localhost"]]

  defp run_ssl(conn) do
    opts = Plug.SSL.init(@ssl_opts)
    Plug.SSL.call(conn, opts)
  end

  test "plain HTTP requests to the 127.0.0.1 loopback are NOT redirected to https" do
    conn =
      conn(:get, "http://127.0.0.1/status/alive")
      |> Map.put(:scheme, :http)
      |> Map.put(:host, "127.0.0.1")
      |> run_ssl()

    refute conn.status in [301, 307, 308],
           "expected 127.0.0.1 to be excluded from the https redirect, " <>
             "but Plug.SSL redirected with status #{inspect(conn.status)} " <>
             "to #{inspect(get_resp_header(conn, "location"))}"

    refute conn.halted,
           "expected the request to pass through, but Plug.SSL halted it"
  end

  test "plain HTTP requests to localhost are still NOT redirected to https" do
    # Sanity check that localhost remains excluded (this passes today).
    conn =
      conn(:get, "http://localhost/status/alive")
      |> Map.put(:scheme, :http)
      |> Map.put(:host, "localhost")
      |> run_ssl()

    refute conn.status in [301, 307, 308]
    refute conn.halted
  end
end

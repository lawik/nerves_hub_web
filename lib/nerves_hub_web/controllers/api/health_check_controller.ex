defmodule NervesHubWeb.API.HealthCheckController do
  @moduledoc "A health check for the app"

  use NervesHubWeb, :api_controller

  @doc """
  Just return a 200 response.

  We could expand this to include a test query to the database.
  """
  def health_check(conn, _),
    do: json(conn, %{status: "UP"})

  def timestamp(conn, _),
    do: json(conn, %{time: System.system_time(:second)})
end

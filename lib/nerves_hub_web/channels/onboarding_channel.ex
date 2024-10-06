defmodule NervesHubWeb.OnboardingChannel do
  @moduledoc """
  Primary websocket channel for device communication

  Handles device logic for updating and tracking devices
  """

  use Phoenix.Channel

  require Logger

  alias NervesHub.Devices
  alias NervesHub.Devices.Device
  alias NervesHub.Products

  def join("onboarding", _params, %{assigns: %{device: device}} = socket) do
    unique =
      {DateTime.utc_now(), :erlang.unique_integer()}
      |> :erlang.term_to_binary()

    # The token is a unique string for this onboarding attempt
    {:ok, token} = Phoenix.Token.sign(conn, "onbarding token", unique)

    Phoenix.Pubsub.subscribe(NervesHub.PubSub, "onboarding:#{token}")

    # Return the token, the device should display a URL with this token that lets
    # an operator go in and perform setup and adopt the device
    {:ok, %{token: token, url: ~p"/onboarding/device/#{token}"}, assign(socket, token: token)}
  end

  def handle_info({:onboarded, token, key, secret}, socket) do
    push(socket, "success", %{key: key, secret: secret})
    {:noreply, socket}
  end
end

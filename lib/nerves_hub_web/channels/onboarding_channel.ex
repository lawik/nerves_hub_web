defmodule NervesHubWeb.OnboardingChannel do
  use NervesHubWeb, :channel

  alias Phoenix.Socket.Broadcast

  def join("shared-secret:" <> device_request_id, _metadata, socket) do
    {:ok, assign(socket, device_request_id: device_request_id)}
  end
end

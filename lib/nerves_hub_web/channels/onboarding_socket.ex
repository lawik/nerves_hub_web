defmodule NervesHubWeb.OnboardingSocket do
  use Phoenix.Socket

  require Logger

  channel("shared-secret:*", NervesHubWeb.OnboardingChannel)

  def connect(_, socket) do
    {:ok, socket}
  end
end

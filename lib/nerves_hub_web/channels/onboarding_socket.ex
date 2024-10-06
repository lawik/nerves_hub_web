defmodule NervesHubWeb.OnboardingSocket do
  use Phoenix.Socket

  channel("onboarding", NervesHubWeb.OnboardingChannel)

  def connect(_, socket) do
    {:ok, socket}
  end
end

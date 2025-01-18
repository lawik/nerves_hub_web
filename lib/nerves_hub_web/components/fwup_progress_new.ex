defmodule NervesHubWeb.Components.FwupProgressNew do
  use NervesHubWeb, :component

  attr(:fwup_progress, :any)

  def render(assigns) do
    ~H"""
    <div class="sticky top-0 w-full h-0 overflow-visible">
      <div class="h-[1px] bg-success-500" role="progressbar" style={"width: #{@fwup_progress}%"} />
      <div class="text-center pt-2 text-sm animate-pulse">Updating firmware <%= @fwup_progress %>%</div>
    </div>
    """
  end
end

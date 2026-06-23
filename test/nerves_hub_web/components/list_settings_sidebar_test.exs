defmodule NervesHubWeb.Components.ListSettingsSidebarTest do
  @moduledoc """
  Reproduction for lawik/nerves_hub_web#15.

  When every column has been hidden, the persisted preference is an empty list
  `[]` (meaning "none selected"), as opposed to `nil` (the default, meaning
  "all selected"). The table correctly shows no columns, but the settings
  sidebar incorrectly renders every checkbox as ticked because `selected?/2`
  treats an empty list the same as the "all selected" default.

  This test is EXPECTED TO FAIL until the bug is fixed.
  """
  use NervesHubWeb.ConnCase.Browser, async: true

  alias NervesHubWeb.Components.ListSettingsSidebar

  describe "settings sidebar with every column hidden" do
    test "checkboxes are not ticked when an empty selection is persisted", %{
      conn: conn,
      fixture: %{user: user, org: org, product: product}
    } do
      assert is_nil(user.display_preferences)

      # Simulate the user unchecking every column in the sidebar. With all
      # columns set to "false" the persisted selection becomes the empty list,
      # which means "show no columns".
      all_columns_hidden =
        %{"_target" => ["health"]}
        |> Map.merge(%{
          "health" => "false",
          "firmware" => "false",
          "platform" => "false",
          "connected_info" => "false",
          "deployment_group" => "false",
          "tags" => "false"
        })

      {:ok, updated_user} =
        ListSettingsSidebar.update_displayed_columns(
          user,
          :device_list_columns,
          all_columns_hidden
        )

      # The preference is genuinely an empty list, not nil. nil would mean
      # "all selected" (the default); [] means "none selected".
      assert updated_user.display_preferences.device_list_columns == []

      session =
        conn
        |> visit(~p"/org/#{org}/#{product}/devices")
        |> assert_has("#device-count", text: "1", timeout: 1000)
        # The table correctly shows no optional columns.
        |> refute_has("th", text: "Health")
        |> click_button("#header button[phx-click=toggle-settings]", "")

      # The sidebar should reflect that no columns are selected, so the
      # Health checkbox must NOT be checked. With the bug present it is checked
      # because selected?/2 collapses [] into the "all selected" default.
      refute_has(session, "#settings-form input[type=checkbox][name=health]", checked: true)
    end
  end
end

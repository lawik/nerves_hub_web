defmodule NervesHubWeb.API.DeviceDisplayDeletedTest do
  @moduledoc """
  Reproduction for lawik/nerves_hub_web#3.

  The API device index applies `Repo.exclude_deleted()` (deleted_at IS NULL)
  before `DeviceFiltering.build_filters/2` runs. As a result the OpenAPI-advertised
  `filters[display_deleted]` values are non-functional on the index endpoint:

    * `only`    -> adds `deleted_at IS NOT NULL` on top of the already-applied
                   `deleted_at IS NULL`, so it returns 0 rows.
    * `include` -> only adds an `order_by`, so deleted devices remain filtered out
                   by the earlier `deleted_at IS NULL`.

  These tests encode the CORRECT (documented) behavior and are EXPECTED TO FAIL
  until the bug is fixed.
  """
  use NervesHubWeb.APIConnCase, async: true

  alias NervesHub.Devices
  alias NervesHub.Fixtures

  describe "index filters[display_deleted]" do
    test "display_deleted=only returns soft-deleted devices", %{
      conn: conn,
      user: user,
      tmp_dir: tmp_dir
    } do
      org = Fixtures.org_fixture(user, %{name: "DisplayDeletedOnly"})
      product = Fixtures.product_fixture(user, org, %{name: "display_deleted_only"})
      org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
      firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})

      device = Fixtures.device_fixture(org, product, firmware)
      {:ok, deleted_device} = Devices.delete_device(device)
      assert deleted_device.deleted_at

      conn =
        get(
          conn,
          Routes.api_device_path(conn, :index, org.name, product.name, %{
            filters: %{display_deleted: "only"}
          })
        )

      assert %{"data" => data} = json_response(conn, 200)

      identifiers = Enum.map(data, & &1["identifier"])

      assert device.identifier in identifiers,
             "expected display_deleted=only to return the soft-deleted device, got: #{inspect(identifiers)}"
    end

    test "display_deleted=include returns both live and soft-deleted devices", %{
      conn: conn,
      user: user,
      tmp_dir: tmp_dir
    } do
      org = Fixtures.org_fixture(user, %{name: "DisplayDeletedInclude"})
      product = Fixtures.product_fixture(user, org, %{name: "display_deleted_include"})
      org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
      firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})

      live_device = Fixtures.device_fixture(org, product, firmware, %{identifier: "live-device"})
      to_delete = Fixtures.device_fixture(org, product, firmware, %{identifier: "deleted-device"})
      {:ok, deleted_device} = Devices.delete_device(to_delete)
      assert deleted_device.deleted_at

      conn =
        get(
          conn,
          Routes.api_device_path(conn, :index, org.name, product.name, %{
            filters: %{display_deleted: "include"}
          })
        )

      assert %{"data" => data} = json_response(conn, 200)

      identifiers = Enum.map(data, & &1["identifier"])

      assert live_device.identifier in identifiers,
             "expected display_deleted=include to return the live device, got: #{inspect(identifiers)}"

      assert to_delete.identifier in identifiers,
             "expected display_deleted=include to also return the soft-deleted device, got: #{inspect(identifiers)}"
    end
  end
end

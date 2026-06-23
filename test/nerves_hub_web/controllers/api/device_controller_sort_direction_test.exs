defmodule NervesHubWeb.API.DeviceControllerSortDirectionTest do
  # Not async: this test inspects the global atom table, which is shared
  # across the VM. Other async tests minting atoms would make the
  # measurement unreliable.
  use NervesHubWeb.APIConnCase, async: false

  alias NervesHub.Fixtures

  describe "index sort_direction" do
    # Refs lawik/nerves_hub_web#1
    #
    # The `sort_direction` query param is passed through `String.to_atom/1`
    # in NervesHubWeb.API.DeviceController.index/2, which mints a brand new,
    # permanent atom for every distinct value. An attacker can exhaust the
    # atom table (a fixed-size, non-GC'd VM resource) by sending many unique
    # values, crashing the node (DoS).
    #
    # `sort_field` correctly uses `String.to_existing_atom/1`, which never
    # creates new atoms. `sort_direction` should do the same (or validate
    # against a known allowlist).
    #
    # This test is EXPECTED TO FAIL until the bug is fixed.
    test "does not mint a new atom for an unknown sort_direction value", %{
      conn: conn,
      user: user,
      tmp_dir: tmp_dir
    } do
      org = Fixtures.org_fixture(user, %{name: "AtomTableOrg"})
      product = Fixtures.product_fixture(user, org, %{name: "atom_table_product"})
      org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
      firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
      _device = Fixtures.device_fixture(org, product, firmware)

      # A value that is extremely unlikely to already exist as an atom and
      # is not a valid sort direction. If the controller mints it, the atom
      # table grows by one permanent entry per unique request.
      bogus_direction = "zzqxnotanatom1234"

      # Sanity check: the atom must not exist before the request. If it
      # somehow does, the test is meaningless, so fail loudly.
      refute atom_exists?(bogus_direction),
             "precondition failed: #{bogus_direction} already exists as an atom"

      # The request itself may raise (Ecto rejects the bogus direction as an
      # invalid `order_by`), but crucially String.to_atom/1 has already run by
      # then, so the atom is minted regardless of how the request finishes.
      # We only care about the side effect on the global atom table here.
      try do
        get(
          conn,
          Routes.api_device_path(conn, :index, org.name, product.name, %{
            sort: "identifier",
            sort_direction: bogus_direction
          })
        )
      rescue
        _ -> :ok
      end

      # CORRECT behavior: the request must not create a new permanent atom
      # from attacker-controlled input. With the bug present, the controller
      # calls String.to_atom("zzqxnotanatom1234") and the atom now exists.
      refute atom_exists?(bogus_direction),
             "sort_direction was passed to String.to_atom/1, minting a new permanent atom (atom-table exhaustion DoS)"
    end
  end

  defp atom_exists?(string) do
    _ = String.to_existing_atom(string)
    true
  rescue
    ArgumentError -> false
  end
end

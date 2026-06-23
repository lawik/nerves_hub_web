defmodule NervesHub.FirmwareUpdatesNoInflightTest do
  @moduledoc """
  Regression test for lawik/nerves_hub_web#20 (upstream PR #2709).

  When a device reports a terminal/blocked status (failed/ignored/rescheduled,
  including any status mapped from "fwup error") and there is NO existing
  InflightUpdate, `FirmwareUpdates.fetch_device/2` inserts an empty inflight
  update whose `deployment_group` association is `%Ecto.Association.NotLoaded{}`.

  Because `%Ecto.Association.NotLoaded{}` is truthy, the failed/ignored/
  rescheduled callbacks take the "has deployment group" branch and dereference
  `deployment_group.penalty_timeout_minutes` / `.name`, raising a KeyError
  inside `Repo.transaction`, which crashes the DeviceChannel.

  These tests encode the CORRECT behavior: status_update should NOT raise and
  should return :ok even when no InflightUpdate exists.
  """
  use NervesHub.DataCase, async: true

  alias NervesHub.Devices.InflightUpdate
  alias NervesHub.FirmwareUpdates
  alias NervesHub.Fixtures
  alias NervesHub.Repo

  setup %{tmp_dir: tmp_dir} do
    user = Fixtures.user_fixture()
    org = Fixtures.org_fixture(user)
    product = Fixtures.product_fixture(user, org)
    org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
    firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
    device = Fixtures.device_fixture(org, product, firmware)

    # IMPORTANT: deliberately do NOT create an InflightUpdate for this device.
    refute Repo.exists?(where(InflightUpdate, device_id: ^device.id))

    {:ok, %{device: device}}
  end

  @tag :tmp_dir
  test "\"failed\" status with no inflight update does not crash", %{device: device} do
    assert :ok =
             FirmwareUpdates.status_update("failed", device.id, %{"reason" => "fwup error"})
  end

  @tag :tmp_dir
  test "\"ignored\" status with no inflight update does not crash", %{device: device} do
    assert :ok =
             FirmwareUpdates.status_update("ignored", device.id, %{"reason" => "ignored"})
  end

  @tag :tmp_dir
  test "\"rescheduled\" status with no inflight update does not crash", %{device: device} do
    assert :ok =
             FirmwareUpdates.status_update("rescheduled", device.id, %{
               "delay_for" => to_timeout(minute: 15),
               "reason" => "rescheduled"
             })
  end
end

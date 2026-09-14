defmodule NervesHub.Repro.Finding5RescheduleUnitsTest do
  @moduledoc """
  Regression test: the reschedule delay is in minutes.

  nerves_hub_link's `UpdateManager` turns the client's `{:reschedule, ms}`
  into `delay_for` in **minutes** (`round(ms / 60_000)`, floored at 5) and
  sends `status_update %{status: "rescheduled", delay_for: minutes}`.
  `FirmwareUpdates.status_update/4` used to add `delay_for` as milliseconds,
  so a device asking for 15 minutes was blocked for 15 ms and the
  orchestrator re-offered the update on its next trigger.
  """
  use NervesHub.DataCase, async: true

  alias NervesHub.DeviceLink
  alias NervesHub.DeviceLink.DeviceInfo
  alias NervesHub.Fixtures

  setup %{tmp_dir: tmp_dir} do
    user = Fixtures.user_fixture()
    org = Fixtures.org_fixture(user)
    product = Fixtures.product_fixture(user, org)
    org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
    firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
    deployment_group = Fixtures.deployment_group_fixture(firmware, %{is_active: true, user: user})
    device = Fixtures.device_fixture(org, product, firmware)

    %{device: device, deployment_group: deployment_group}
  end

  test "a device rescheduling by 15 minutes is left alone for 15 minutes", %{
    device: device,
    deployment_group: deployment_group
  } do
    {:ok, _inflight_update} = Fixtures.inflight_update(device, deployment_group)

    # Exactly what nerves_hub_link sends for `{:reschedule, 15 * 60_000}`.
    :ok = DeviceLink.status_update(to_device_info(device), %{"status" => "rescheduled", "delay_for" => 15})

    blocked_until = Repo.reload!(device).updates_blocked_until
    refute is_nil(blocked_until)

    blocked_for_seconds = DateTime.diff(blocked_until, DateTime.utc_now(), :second)
    assert_in_delta blocked_for_seconds, 15 * 60, 60
  end

  defp to_device_info(device) do
    %DeviceInfo{device_id: device.id, device_identifier: device.identifier, product_id: device.product_id}
  end
end

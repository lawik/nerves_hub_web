defmodule NervesHub.Repro.Finding1UnparseableUpdateTest do
  @moduledoc """
  Reproduces: a device can be sent an `update` it cannot act on.

  `DeviceEvents.schedule_update/3` inserts the inflight row, then resolves the
  payload with `Updates.resolve_update/3`, and broadcasts whatever comes back
  — including `%UpdatePayload{update_available: false}` with no
  `firmware_url`. nerves_hub_link's `UpdateInfo.parse/1` needs the URL, so
  the device logs an error and does nothing. Two ways to get there:

  1. A device over its deployment group's failure threshold asks for an
     update. `device_requested_update/1` gates on `check_update/1`, which
     does not look at the attempt counters; `verify_update_eligibility/3`
     inside `schedule_update/3` does, penalty-boxes the device, and the
     answer to the request is the unparseable `update`. The device's
     `start_update/1` times out (30 s) instead of getting `update_rejected`.
  2. `schedule_update/3` runs for a device that is already up to date (a
     race with the orchestrator's query). The inflight row inserted before
     `resolve_update/3` stays behind as `requested`, so the device is
     `already_updating` to its own requests and invisible to the
     orchestrator until the expiry worker clears it 30 minutes later.
  """
  use NervesHub.DataCase, async: true

  alias NervesHub.DeviceEvents
  alias NervesHub.Devices
  alias NervesHub.Devices.Deployments
  alias NervesHub.FirmwareUpdates
  alias NervesHub.Fixtures
  alias NervesHub.ManagedDeployments
  alias Phoenix.Socket.Broadcast

  setup %{tmp_dir: tmp_dir} do
    user = Fixtures.user_fixture()
    org = Fixtures.org_fixture(user)
    product = Fixtures.product_fixture(user, org)
    org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
    firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
    deployment_group = Fixtures.deployment_group_fixture(firmware, %{is_active: true, user: user})

    # Newer firmware on the deployment group than the device runs.
    next = Fixtures.firmware_fixture(org_key, product, %{version: "9.9.9", dir: tmp_dir})

    {:ok, {_release, deployment_group}} =
      ManagedDeployments.create_deployment_release(deployment_group, next, nil, user, %{})

    device = Fixtures.device_fixture(org, product, firmware)
    device = Deployments.update_deployment_group(device, deployment_group)

    :ok = Phoenix.PubSub.subscribe(NervesHub.PubSub, DeviceEvents.topic(device))

    %{
      user: user,
      org: org,
      product: product,
      org_key: org_key,
      firmware: firmware,
      next: next,
      deployment_group: deployment_group,
      device: Repo.reload(device) |> Repo.preload(:deployment_group)
    }
  end

  test "a device over the failure threshold is refused, not sent an update it cannot parse", %{
    device: device,
    deployment_group: deployment_group
  } do
    attempts = for _ <- 1..(deployment_group.device_failure_threshold + 1), do: DateTime.utc_now()
    {:ok, device} = Devices.update_device(device, %{update_attempts: attempts})

    result = DeviceEvents.device_requested_update(device)

    # An `update` without a firmware_url is not something the device can act
    # on; the refusal must come as `update_rejected`, which is what the
    # caller's `{:error, reason}` turns into.
    refute_receive %Broadcast{event: "update", payload: %{update_available: false}}, 200
    assert {:error, _reason} = result
  end

  test "scheduling an update for a device that is already up to date leaves nothing behind", %{
    org: org,
    product: product,
    next: next,
    deployment_group: deployment_group
  } do
    current = Fixtures.device_fixture(org, product, next)
    current = Deployments.update_deployment_group(current, deployment_group)
    :ok = Phoenix.PubSub.subscribe(NervesHub.PubSub, DeviceEvents.topic(current))

    _ = DeviceEvents.schedule_update(current.id, deployment_group)

    refute_receive %Broadcast{event: "update", payload: %{update_available: false}}, 200
    assert is_nil(FirmwareUpdates.inflight_update_for(current)), "an inflight row was left for a device that was not sent an update"
  end
end

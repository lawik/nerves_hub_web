defmodule NervesHub.FirmwareUpdatesTest do
  use NervesHub.DataCase, async: true

  alias NervesHub.AuditLogs
  alias NervesHub.FirmwareUpdates
  alias NervesHub.Fixtures

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    user = Fixtures.user_fixture()
    org = Fixtures.org_fixture(user)
    product = Fixtures.product_fixture(user, org)
    org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
    firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
    device = Fixtures.device_fixture(org, product, firmware, %{status: :provisioned})

    %{device: device, firmware: firmware}
  end

  describe "status_update/4 failed for a manual update" do
    test "records the device-reported reason in the audit log", %{
      device: device,
      firmware: firmware
    } do
      # Manual update => no deployment_id on the inflight update, exercising the
      # non-deployment branch in FirmwareUpdates.status_update("failed", ...).
      {:ok, _inflight} = Fixtures.inflight_update(device, firmware)

      reason = "boom-reason-xyz"

      assert :ok =
               FirmwareUpdates.status_update("failed", device.id, %{"reason" => reason})

      descriptions =
        device
        |> AuditLogs.logs_for()
        |> Enum.map(& &1.description)

      assert Enum.any?(descriptions, &String.contains?(&1, reason)),
             "expected an audit log entry to include the device-reported reason #{inspect(reason)}, got: #{inspect(descriptions)}"
    end
  end
end

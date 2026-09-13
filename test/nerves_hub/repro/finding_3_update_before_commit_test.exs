defmodule NervesHub.Repro.Finding3UpdateBeforeCommitTest do
  @moduledoc """
  Reproduces: the `update` is broadcast to the device before the inflight row
  that describes it is committed.

  `DeviceEvents.schedule_update/3` broadcasts inside the `Repo.transact` that
  inserts the inflight row. A device that answers `status_update received`
  before the commit makes `FirmwareUpdates.fetch_device/2` (on its own
  connection) see no row, insert an empty one, and crash the device channel
  on `inflight_updates_device_id_index`. Observed live with a host device
  answering in 1 ms.

  The race needs two real connections and real commits, so this test runs
  outside the SQL sandbox (`Sandbox.unboxed_run/2`) and cleans up after
  itself. A watcher process — standing in for the device channel — receives
  the broadcast and immediately looks for the row; a telemetry handler
  attached to the event `schedule_update/3` emits *after* the broadcast and
  *inside* the transaction holds the transaction open until the watcher has
  looked, so the outcome does not depend on scheduler timing.
  """
  use ExUnit.Case, async: false

  import Ecto.Query

  alias Ecto.Adapters.SQL.Sandbox
  alias NervesHub.DeviceEvents
  alias NervesHub.Devices.Deployments
  alias NervesHub.Devices.InflightUpdate
  alias NervesHub.Fixtures
  alias NervesHub.ManagedDeployments
  alias NervesHub.Repo
  alias Phoenix.Socket.Broadcast

  @moduletag :tmp_dir
  @telemetry_event [:nerves_hub, :devices, :update, :automatic]

  test "the device is only told about an update once the inflight row is committed", %{tmp_dir: tmp_dir} do
    Sandbox.unboxed_run(Repo, fn ->
      # Unique names: nothing here is rolled back, so a leftover from an
      # earlier run must not collide with this one.
      tag = System.unique_integer([:positive])
      user = Fixtures.user_fixture(%{email: "repro3-#{tag}@example.com", username: "repro3-#{tag}"})
      org = Fixtures.org_fixture(user, %{name: "repro3-org-#{tag}"})
      product = Fixtures.product_fixture(user, org, %{name: "repro3-product-#{tag}"})
      org_key = Fixtures.org_key_fixture(org, user, tmp_dir)
      firmware = Fixtures.firmware_fixture(org_key, product, %{dir: tmp_dir})
      deployment_group = Fixtures.deployment_group_fixture(firmware, %{is_active: true, user: user})
      next = Fixtures.firmware_fixture(org_key, product, %{version: "9.9.9", dir: tmp_dir})

      {:ok, {_release, deployment_group}} =
        ManagedDeployments.create_deployment_release(deployment_group, next, nil, user, %{})

      device = Fixtures.device_fixture(org, product, firmware)
      device = Deployments.update_deployment_group(device, deployment_group)

      test_pid = self()
      topic = DeviceEvents.topic(device)
      device_id = device.id

      # The device channel: on `update`, do what `status_update received`
      # does first — look up the inflight row on its own connection.
      watcher =
        spawn_link(fn ->
          :ok = Phoenix.PubSub.subscribe(NervesHub.PubSub, topic)
          send(test_pid, :subscribed)

          receive do
            %Broadcast{event: "update"} ->
              # On its own, real connection — like the device channel's.
              visible? =
                Sandbox.unboxed_run(Repo, fn ->
                  Repo.exists?(from(i in InflightUpdate, where: i.device_id == ^device_id))
                end)

              send(test_pid, {:row_visible_at_broadcast, visible?})
          after
            5_000 -> send(test_pid, :no_broadcast)
          end
        end)

      assert_receive :subscribed, 1_000

      # Runs in this process, after the broadcast, still inside the
      # transaction: wait for the watcher's verdict before letting the
      # transaction go on to commit.
      :ok =
        :telemetry.attach(
          "repro-finding-3",
          @telemetry_event,
          fn _event, _measurements, _meta, _config ->
            receive do
              {:row_visible_at_broadcast, _} = verdict -> send(self(), verdict)
            after
              3_000 -> send(self(), :watcher_did_not_answer)
            end
          end,
          nil
        )

      try do
        {:ok, _inflight} = DeviceEvents.schedule_update(device.id, deployment_group)

        assert_receive {:row_visible_at_broadcast, visible?}, 5_000

        assert visible?,
               "the update was broadcast while the inflight row was still uncommitted; " <>
                 "a device answering `received` at that moment crashes its channel"
      after
        :telemetry.detach("repro-finding-3")
        Process.exit(watcher, :kill)
        cleanup(org, user)
      end
    end)
  end

  # Outside the sandbox nothing is rolled back for us. Everything the
  # fixtures made hangs off the org (and the user), so delete those; rows
  # that reference them without a cascade are removed first.
  defp cleanup(org, user) do
    Repo.delete_all(from(i in InflightUpdate, join: d in assoc(i, :device), where: d.org_id == ^org.id))
    Repo.delete_all(from(d in NervesHub.Devices.Device, where: d.org_id == ^org.id))
    Repo.update_all(from(dg in NervesHub.ManagedDeployments.DeploymentGroup, where: dg.org_id == ^org.id), set: [current_deployment_release_id: nil])
    Repo.delete_all(from(r in NervesHub.ManagedDeployments.DeploymentRelease, join: dg in assoc(r, :deployment_group), where: dg.org_id == ^org.id))
    Repo.delete_all(from(dg in NervesHub.ManagedDeployments.DeploymentGroup, where: dg.org_id == ^org.id))
    Repo.delete_all(from(f in NervesHub.Firmwares.Firmware, where: f.org_id == ^org.id))
    Repo.delete_all(from(a in NervesHub.AuditLogs.AuditLog, where: a.org_id == ^org.id))
    Repo.delete_all(from(p in NervesHub.Products.Product, where: p.org_id == ^org.id))
    Repo.delete_all(from(k in NervesHub.Accounts.OrgKey, where: k.org_id == ^org.id))
    Repo.delete_all(from(ou in NervesHub.Accounts.OrgUser, where: ou.org_id == ^org.id))
    Repo.delete_all(from(o in NervesHub.Accounts.Org, where: o.id == ^org.id))
    Repo.delete_all(from(u in NervesHub.Accounts.User, where: u.id == ^user.id))
    :ok
  rescue
    e -> IO.puts("cleanup left rows in the test database: #{Exception.message(e)}")
  end
end

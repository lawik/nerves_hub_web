defmodule NervesHub.Repo.Migrations.AddDeviceHealthIndex do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX device_health_data_gin ON device_health USING gin (data)")
  end

  def down do
    execute("DROP INDEX device_health_data_gin")
  end
end

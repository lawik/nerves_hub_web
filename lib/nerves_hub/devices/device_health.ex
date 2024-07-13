defmodule NervesHub.Devices.DeviceHealth do
  use Ecto.Schema

  import Ecto.Changeset

  alias NervesHub.Devices.Device

  alias __MODULE__

  @type t :: %__MODULE__{}
  @required_params [:device_id, :data]

  schema "device_health" do
    belongs_to(:device, Device)
    field(:data, :map)
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def save(params) do
    %DeviceHealth{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end

  def to_flat(%DeviceHealth{data: data, inserted_at: timestamp, device_id: device_id}) do
    flat = %{
      "device_id" => device_id,
      "timestamp" => timestamp
    }

    flat =
      data
      |> Map.get("metrics", %{})
      |> Enum.reduce(flat, fn {name, value}, flat ->
        Map.put(flat, "metric_#{name}", value)
      end)

    flat =
      data
      |> Map.get("alarms", %{})
      |> Enum.reduce(flat, fn {alarm_id, _description}, flat ->
        lower_alarm_id = Recase.to_snake(alarm_id)
        Map.put(flat, "alarm_#{lower_alarm_id}", true)
      end)

    flat =
      data
      |> Map.get("metadata", %{})
      |> Enum.reduce(flat, fn {key, value}, flat ->
        Map.put(flat, "metadata_#{key}", value)
      end)
  end

  def add_nils_for_flats(flats) do

    keys =
      flats
      |> Enum.flat_map(& Map.keys(&1))
      |> Enum.uniq()

    nils =
      keys
      |> Enum.map(& {&1, nil})
      |> Map.new()

    flats
    |> Enum.map(fn map ->
      Map.merge(nils, map)
    end)
  end
end

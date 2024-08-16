defmodule NervesHub.Dev do
  if Mix.env() == :dev do
    alias NervesHub.Accounts
    alias NervesHub.Devices
    alias NervesHub.Products

    require Logger

    def update_locations(org_name, product_name) do
      {:ok, o} = Accounts.get_org_by_name(org_name)
      {:ok, p} = Products.get_product_by_org_id_and_name(o.id, product_name)
      {:ok, pid} = Task.start_link(fn ->
        update_location_constantly(o.id, p.id, 0)
      end)
      Process.put(:location_task, pid)
    end

    defp update_location_constantly(org_id, product_id, offset) do
      result = Devices.get_devices_by_org_id_and_product_id(org_id, product_id, %{pagination: %{page_number: offset, page_size: 1}})
      Logger.info("Jiggling device at offset: #{offset}")

      next_offset = 
        case result.entries do
          [] -> 1
          [%{connection_metadata: %{
              "location" => %{
                "longitude" => lng,
                "latitude" => lat,
                "source" => _source
              }
             } = meta} = d] ->
              loc = %{
                "longitude" => move_slightly(lng),
                "latitude" => move_slightly(lat),
                "source" => "dev"
              }
            {:ok, _} = Devices.update_device(d, %{connection_metadata: Map.put(meta, "location", loc)})
            offset + 1
          [%{connection_metadata: meta} = d] ->
              loc = %{
                "longitude" => new_longitude(),
                "latitude" => new_latitude(),
                "source" => "dev" 
              }
            {:ok, _} = Devices.update_device(d, %{connection_metadata: Map.put(meta, "location", loc)})
            offset + 1
        end

      :timer.sleep(100)
      update_location_constantly(org_id, product_id, next_offset)
    end

    defp move_slightly(num) do
      num + (Enum.random(-1..1) / 10)
    end

    defp new_longitude do
      Enum.random(-180..180)
    end

    defp new_latitude do
      Enum.random(-90..90)
    end

    defp stop_locations do
      if pid = Process.get(:location_task) do
        Process.exit(pid, :murder)
      end
    end
  end
end
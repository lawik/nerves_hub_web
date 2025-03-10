defmodule Hub.DeviceMetric do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "device_metrics"
    repo NervesHub.Repo
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end

    attribute :key, :string do
      public? true
    end

    attribute :value, :decimal do
      public? true
    end

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :device, Hub.Device do
      allow_nil? false
      attribute_type :integer
      public? true
    end
  end
end

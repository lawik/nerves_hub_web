defmodule Hub.DeviceConnection do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "device_connections"
    repo NervesHub.Repo
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end

    attribute :status, :string do
      public? true
    end

    attribute :established_at, :utc_datetime_usec do
      public? true
    end

    attribute :last_seen_at, :utc_datetime_usec do
      public? true
    end

    attribute :disconnected_at, :utc_datetime_usec do
      public? true
    end

    attribute :disconnected_reason, :string do
      public? true
    end

    attribute :metadata, :map do
      generated? true
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

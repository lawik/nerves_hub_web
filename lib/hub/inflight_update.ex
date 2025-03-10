defmodule Hub.InflightUpdate do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "inflight_updates"
    repo NervesHub.Repo
    migrate? false

    identity_index_names device_id_deployment_id: "inflight_updates_device_id_deployment_id_index"
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

    attribute :firmware_uuid, :uuid do
      allow_nil? false
      public? true
    end

    attribute :status, :string do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :expires_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :deployment, Hub.Deployment do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :device, Hub.Device do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :firmware, Hub.Firmware do
      allow_nil? false
      attribute_type :integer
      public? true
    end
  end

  identities do
    identity :device_id_deployment_id, [:device_id, :deployment_id]
  end
end

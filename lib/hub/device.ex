defmodule Hub.Device do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "devices"
    repo NervesHub.Repo
    migrate? false

    identity_index_names identifier: "devices_identifier_index"
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

    attribute :identifier, :string do
      allow_nil? false
      public? true
    end

    attribute :tags, {:array, :string} do
      public? true
    end

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    update_timestamp :updated_at do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :firmware_metadata, :map do
      public? true
    end

    attribute :updates_enabled, :boolean do
      generated? true
      public? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      public? true
    end

    attribute :update_attempts, {:array, :utc_datetime_usec} do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :updates_blocked_until, :utc_datetime_usec do
      public? true
    end

    attribute :connecting_code, :string do
      public? true
    end

    attribute :connection_metadata, :map do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :connection_status, :string do
      public? true
    end

    attribute :connection_established_at, :utc_datetime_usec do
      public? true
    end

    attribute :connection_disconnected_at, :utc_datetime_usec do
      public? true
    end

    attribute :connection_last_seen_at, :utc_datetime_usec do
      public? true
    end

    attribute :status, :string do
      public? true
    end

    attribute :first_seen_at, :utc_datetime_usec do
      public? true
    end

    attribute :extensions, :map do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :latest_connection_id, :uuid do
      public? true
    end

    attribute :latest_health_id, :integer do
      sensitive? true
      public? true
    end
  end

  relationships do
    belongs_to :deployment, Hub.Deployment do
      attribute_type :integer
      public? true
    end

    belongs_to :org, Hub.Org do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :product, Hub.Product do
      attribute_type :integer
      public? true
    end

    has_many :device_certificates, Hub.DeviceCertificate do
      public? true
    end

    has_many :device_connections, Hub.DeviceConnection do
      public? true
    end

    has_many :device_healths, Hub.DeviceHealth do
      public? true
    end

    has_many :device_metrics, Hub.DeviceMetric do
      public? true
    end

    has_many :device_shared_secret_auths, Hub.DeviceSharedSecretAuth do
      public? true
    end

    has_many :inflight_deployment_checks, Hub.InflightDeploymentCheck do
      public? true
    end

    has_many :inflight_updates, Hub.InflightUpdate do
      public? true
    end

    has_many :pinned_devices, Hub.PinnedDevice do
      public? true
    end
  end

  identities do
    identity :identifier, [:identifier]
  end
end

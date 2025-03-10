defmodule Hub.Deployment do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "deployments"
    repo NervesHub.Repo
    migrate? false

    identity_index_names product_id_name: "deployments_product_id_name_index"
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

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :conditions, :map do
      allow_nil? false
      generated? true
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

    attribute :is_active, :boolean do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :healthy, :boolean do
      sensitive? true
      generated? true
      public? true
    end

    attribute :connecting_code, :string do
      public? true
    end

    attribute :orchestrator_strategy, :string do
      public? true
    end

    attribute :device_failure_threshold, :integer do
      default 3
      generated? true
      public? true
    end

    attribute :device_failure_rate_seconds, :integer do
      default 180
      generated? true
      public? true
    end

    attribute :device_failure_rate_amount, :integer do
      default 5
      generated? true
      public? true
    end

    attribute :failure_threshold, :integer do
      default 50
      generated? true
      public? true
    end

    attribute :failure_rate_seconds, :integer do
      default 300
      generated? true
      public? true
    end

    attribute :failure_rate_amount, :integer do
      default 5
      generated? true
      public? true
    end

    attribute :penalty_timeout_minutes, :integer do
      allow_nil? false
      default 1440
      generated? true
      public? true
    end

    attribute :concurrent_updates, :integer do
      allow_nil? false
      default 10
      generated? true
      public? true
    end

    attribute :total_updating_devices, :integer do
      allow_nil? false
      default 0
      generated? true
      public? true
    end

    attribute :current_updated_devices, :integer do
      allow_nil? false
      default 0
      generated? true
      public? true
    end

    attribute :inflight_update_expiration_minutes, :integer do
      allow_nil? false
      default 60
      generated? true
      public? true
    end

    attribute :recalculation_type, :string do
      allow_nil? false
      default "device"
      generated? true
      public? true
    end
  end

  relationships do
    belongs_to :archive, Hub.Archive do
      attribute_type :integer
      public? true
    end

    belongs_to :firmware, Hub.Firmware do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :org, Hub.Org do
      attribute_type :integer
      public? true
    end

    belongs_to :product, Hub.Product do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    has_many :devices, Hub.Device do
      public? true
    end

    has_many :inflight_deployment_checks, Hub.InflightDeploymentCheck do
      public? true
    end

    has_many :inflight_updates, Hub.InflightUpdate do
      public? true
    end
  end

  identities do
    identity :product_id_name, [:product_id, :name]
  end
end

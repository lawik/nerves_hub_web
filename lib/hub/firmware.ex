defmodule Hub.Firmware do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "firmwares"
    repo NervesHub.Repo
    migrate? false

    identity_index_names product_id_uuid: "firmwares_product_id_uuid_index"
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

    attribute :platform, :string do
      allow_nil? false
      public? true
    end

    attribute :architecture, :string do
      allow_nil? false
      public? true
    end

    attribute :upload_metadata, :map do
      allow_nil? false
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

    attribute :version, :string do
      allow_nil? false
      public? true
    end

    attribute :author, :string do
      sensitive? true
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :misc, :string do
      public? true
    end

    attribute :uuid, :string do
      allow_nil? false
      public? true
    end

    attribute :vcs_identifier, :string do
      public? true
    end

    attribute :size, :integer do
      public? true
    end

    attribute :delta_updatable, :boolean do
      generated? true
      public? true
    end
  end

  relationships do
    belongs_to :org, Hub.Org do
      attribute_type :integer
      public? true
    end

    belongs_to :org_key, Hub.OrgKey do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :product, Hub.Product do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    has_many :deployments, Hub.Deployment do
      public? true
    end

    has_many :inflight_updates, Hub.InflightUpdate do
      public? true
    end
  end

  identities do
    identity :product_id_uuid, [:product_id, :uuid]
  end
end

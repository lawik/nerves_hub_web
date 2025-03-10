defmodule Hub.Product do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "products"
    repo NervesHub.Repo
    migrate? false

    skip_unique_indexes [:org_id_name]

    identity_index_names org_id_name: "products_org_id_name_index"
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

    attribute :delta_updatable, :boolean do
      generated? true
      public? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      public? true
    end

    attribute :extensions, :map do
      allow_nil? false
      generated? true
      public? true
    end
  end

  relationships do
    belongs_to :org, Hub.Org do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    has_many :archives, Hub.Archive do
      public? true
    end

    has_many :deployments, Hub.Deployment do
      public? true
    end

    has_many :devices, Hub.Device do
      public? true
    end

    has_many :firmwares, Hub.Firmware do
      public? true
    end

    has_many :jitps, Hub.Jitp do
      public? true
    end

    has_many :product_shared_secret_auths, Hub.ProductSharedSecretAuth do
      public? true
    end

    has_many :product_users, Hub.ProductUser do
      public? true
    end

    has_many :scripts, Hub.Script do
      public? true
    end
  end

  identities do
    identity :org_id_name, [:org_id, :name] do
      # Express `(deleted_at IS NULL)` as an Ash expression
      # where expr(...)
    end
  end
end

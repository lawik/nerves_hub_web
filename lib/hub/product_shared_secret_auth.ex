defmodule Hub.ProductSharedSecretAuth do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "product_shared_secret_auth"
    repo NervesHub.Repo
    migrate? false

    identity_index_names key: "product_shared_secret_auth_key_index",
                         secret: "product_shared_secret_auth_secret_index"
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
      allow_nil? false
      public? true
    end

    attribute :secret, :string do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :deactivated_at, :utc_datetime_usec do
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
  end

  relationships do
    belongs_to :product, Hub.Product do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    has_many :device_shared_secret_auths, Hub.DeviceSharedSecretAuth do
      public? true
    end
  end

  identities do
    identity :key, [:key]
    identity :secret, [:secret]
  end
end

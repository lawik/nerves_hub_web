defmodule Hub.Jitp do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "jitp"
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

    attribute :tags, {:array, :string} do
      public? true
    end

    attribute :description, :string do
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

    has_many :ca_certificates, Hub.CaCertificate do
      public? true
    end
  end
end

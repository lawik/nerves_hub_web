defmodule Hub.OrgKey do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "org_keys"
    repo NervesHub.Repo
    migrate? false

    identity_index_names org_id_key: "org_keys_org_id_key_index",
                         org_id_name: "org_keys_org_id_name_index"
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

    attribute :key, :string do
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
  end

  relationships do
    belongs_to :org, Hub.Org do
      allow_nil? false
      attribute_type :integer
      public? true
    end

    belongs_to :user, Hub.User do
      source_attribute :created_by_id
      attribute_type :integer
      public? true
    end

    has_many :archives, Hub.Archive do
      public? true
    end

    has_many :firmwares, Hub.Firmware do
      public? true
    end
  end

  identities do
    identity :org_id_key, [:org_id, :key]
    identity :org_id_name, [:org_id, :name]
  end
end

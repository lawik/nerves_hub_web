defmodule Hub.OrgUser do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "org_users"
    repo NervesHub.Repo
    migrate? false

    skip_unique_indexes [:index]

    identity_index_names index: "org_users_index"
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

    attribute :role, :string do
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

    attribute :deleted_at, :utc_datetime_usec do
      public? true
    end
  end

  relationships do
    belongs_to :org, Hub.Org do
      attribute_type :integer
      public? true
    end

    belongs_to :user, Hub.User do
      attribute_type :integer
      public? true
    end
  end

  identities do
    identity :index, [:org_id, :user_id] do
      # Express `(deleted_at IS NULL)` as an Ash expression
      # where expr(...)
    end
  end
end

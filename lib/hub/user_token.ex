defmodule Hub.UserToken do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_tokens"
    repo NervesHub.Repo
    migrate? false

    identity_index_names token: "user_tokens_token_index"
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

    attribute :token, :string do
      sensitive? true
      public? true
    end

    attribute :note, :string do
      public? true
    end

    attribute :last_used, :utc_datetime_usec do
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
    belongs_to :user, Hub.User do
      attribute_type :integer
      public? true
    end
  end

  identities do
    identity :token, [:token]
  end
end

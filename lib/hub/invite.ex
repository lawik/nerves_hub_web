defmodule Hub.Invite do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "invites"
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

    attribute :email, :string do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :token, :uuid do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :accepted, :boolean do
      allow_nil? false
      sensitive? true
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

    attribute :role, :string do
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
      source_attribute :invited_by_id
      attribute_type :integer
      public? true
    end
  end
end

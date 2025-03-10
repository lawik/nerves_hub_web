defmodule Hub.AuditLog do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "audit_logs"
    repo NervesHub.Repo
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
    end

    attribute :actor_id, :integer do
      allow_nil? false
      public? true
    end

    attribute :actor_type, :string do
      allow_nil? false
      public? true
    end

    attribute :params, :map do
      public? true
    end

    attribute :resource_id, :integer do
      allow_nil? false
      public? true
    end

    attribute :resource_type, :string do
      allow_nil? false
      public? true
    end

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :changes, :map do
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :reference_id, :string do
      public? true
    end
  end

  relationships do
    belongs_to :org, Hub.Org do
      attribute_type :integer
      public? true
    end
  end
end

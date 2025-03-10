defmodule Hub.Script do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "scripts"
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

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :text, :string do
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

    attribute :created_by_id, :integer do
      public? true
    end

    attribute :last_updated_by_id, :integer do
      public? true
    end
  end

  relationships do
    belongs_to :product, Hub.Product do
      allow_nil? false
      attribute_type :integer
      public? true
    end
  end
end

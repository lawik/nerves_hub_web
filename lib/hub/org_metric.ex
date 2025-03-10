defmodule Hub.OrgMetric do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "org_metrics"
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

    attribute :devices, :integer do
      allow_nil? false
      public? true
    end

    attribute :bytes_stored, :integer do
      allow_nil? false
      public? true
    end

    attribute :timestamp, :utc_datetime_usec do
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
  end
end

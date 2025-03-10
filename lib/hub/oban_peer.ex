defmodule Hub.ObanPeer do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "oban_peers"
    repo NervesHub.Repo
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :name, :string do
      primary_key? true
      allow_nil? false
      public? true
    end

    attribute :node, :string do
      allow_nil? false
      public? true
    end

    attribute :started_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :expires_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end
  end
end

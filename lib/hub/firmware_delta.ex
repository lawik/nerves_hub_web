defmodule Hub.FirmwareDelta do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "firmware_deltas"
    repo NervesHub.Repo
    migrate? false

    identity_index_names source_id_target_id: "source_id_target_id_unique_index"
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

    attribute :source_id, :integer do
      allow_nil? false
      public? true
    end

    attribute :target_id, :integer do
      allow_nil? false
      public? true
    end

    attribute :upload_metadata, :map do
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

  identities do
    identity :source_id_target_id, [:source_id, :target_id]
  end
end

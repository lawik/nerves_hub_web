defmodule Hub.CaCertificate do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ca_certificates"
    repo NervesHub.Repo
    migrate? false

    identity_index_names jitp_id: "ca_certificates_jitp_id_index",
                         serial: "ca_certificates_serial_index"
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

    attribute :serial, :string do
      allow_nil? false
      public? true
    end

    attribute :aki, :binary do
      public? true
    end

    attribute :ski, :binary do
      public? true
    end

    attribute :not_before, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :not_after, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :der, :binary do
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

    attribute :last_used, :utc_datetime_usec do
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :check_expiration, :boolean do
      public? true
    end
  end

  relationships do
    belongs_to :jitp, Hub.Jitp do
      attribute_type :integer
      public? true
    end

    belongs_to :org, Hub.Org do
      allow_nil? false
      attribute_type :integer
      public? true
    end
  end

  identities do
    identity :jitp_id, [:jitp_id]
    identity :serial, [:serial]
  end
end

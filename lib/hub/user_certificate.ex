defmodule Hub.UserCertificate do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_certificates"
    repo NervesHub.Repo
    migrate? false

    identity_index_names user_id_serial: "user_certificates_user_id_serial_index"
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

    attribute :description, :string do
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

    attribute :not_before, :utc_datetime_usec do
      public? true
    end

    attribute :not_after, :utc_datetime_usec do
      public? true
    end

    attribute :ski, :binary do
      public? true
    end

    attribute :aki, :binary do
      public? true
    end

    attribute :last_used, :utc_datetime_usec do
      public? true
    end
  end

  relationships do
    belongs_to :user, Hub.User do
      allow_nil? false
      attribute_type :integer
      public? true
    end
  end

  identities do
    identity :user_id_serial, [:user_id, :serial]
  end
end

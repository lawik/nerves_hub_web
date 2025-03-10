defmodule Hub.User do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo NervesHub.Repo
    migrate? false

    skip_unique_indexes [:email]

    identity_index_names email: "users_email_index"
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

    attribute :username, :string do
      allow_nil? false
      public? true
    end

    attribute :email, :string do
      allow_nil? false
      sensitive? true
      public? true
    end

    attribute :password_hash, :string do
      allow_nil? false
      sensitive? true
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

    attribute :password_reset_token, :uuid do
      sensitive? true
      public? true
    end

    attribute :password_reset_token_expires, :utc_datetime_usec do
      sensitive? true
      public? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      public? true
    end

    attribute :server_role, :string do
      public? true
    end
  end

  relationships do
    has_many :invites, Hub.Invite do
      destination_attribute :invited_by_id
      public? true
    end

    has_many :org_keys, Hub.OrgKey do
      destination_attribute :created_by_id
      public? true
    end

    has_many :org_users, Hub.OrgUser do
      public? true
    end

    has_many :pinned_devices, Hub.PinnedDevice do
      public? true
    end

    has_many :product_users, Hub.ProductUser do
      public? true
    end

    has_many :user_certificates, Hub.UserCertificate do
      public? true
    end

    has_many :user_tokens, Hub.UserToken do
      public? true
    end
  end

  identities do
    identity :email, [:email] do
      # Express `(deleted_at IS NULL)` as an Ash expression
      # where expr(...)
    end
  end
end

defmodule Hub.Org do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "orgs"
    repo NervesHub.Repo
    migrate? false

    skip_unique_indexes [:name]

    identity_index_names name: "orgs_name_index"
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

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    update_timestamp :updated_at do
      allow_nil? false
      public? true
    end

    attribute :deleted_at, :utc_datetime_usec do
      public? true
    end

    attribute :audit_log_days_to_keep, :integer do
      public? true
    end
  end

  relationships do
    has_many :audit_logs, Hub.AuditLog do
      public? true
    end

    has_many :ca_certificates, Hub.CaCertificate do
      public? true
    end

    has_many :deployments, Hub.Deployment do
      public? true
    end

    has_many :device_certificates, Hub.DeviceCertificate do
      public? true
    end

    has_many :devices, Hub.Device do
      public? true
    end

    has_many :firmware_transfers, Hub.FirmwareTransfer do
      public? true
    end

    has_many :firmwares, Hub.Firmware do
      public? true
    end

    has_many :invites, Hub.Invite do
      public? true
    end

    has_many :org_keys, Hub.OrgKey do
      public? true
    end

    has_many :org_metrics, Hub.OrgMetric do
      public? true
    end

    has_many :org_users, Hub.OrgUser do
      public? true
    end

    has_many :products, Hub.Product do
      public? true
    end
  end

  identities do
    identity :name, [:name] do
      # Express `(deleted_at IS NULL)` as an Ash expression
      # where expr(...)
    end
  end
end

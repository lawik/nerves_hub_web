defmodule Hub.ObanJob do
  use Ash.Resource,
    domain: Hub,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "oban_jobs"
    repo NervesHub.Repo
    migrate? false

    identity_index_names args_scheduled_at_worker: "oban_jobs_args_scheduled_at_worker_index"
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

    attribute :worker, :string do
      allow_nil? false
      public? true
    end

    attribute :args, :map do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :errors, {:array, :map} do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :scheduled_at, :utc_datetime_usec do
      allow_nil? false
      generated? true
      public? true
    end

    attribute :attempted_at, :utc_datetime_usec do
      public? true
    end

    attribute :completed_at, :utc_datetime_usec do
      public? true
    end

    attribute :attempted_by, {:array, :string} do
      public? true
    end

    attribute :discarded_at, :utc_datetime_usec do
      public? true
    end

    attribute :tags, {:array, :string} do
      generated? true
      public? true
    end

    attribute :meta, :map do
      generated? true
      public? true
    end

    attribute :cancelled_at, :utc_datetime_usec do
      public? true
    end

    attribute :queue, :string do
      allow_nil? false
      default "default"
      generated? true
      public? true
    end

    attribute :attempt, :integer do
      allow_nil? false
      default 0
      generated? true
      public? true
    end

    attribute :max_attempts, :integer do
      allow_nil? false
      default 20
      generated? true
      public? true
    end

    attribute :priority, :integer do
      allow_nil? false
      default 0
      generated? true
      public? true
    end
  end

  identities do
    identity :args_scheduled_at_worker, [:args, :scheduled_at, :worker]
  end
end

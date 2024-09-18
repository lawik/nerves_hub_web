defmodule NervesHubWeb.API.SharedSecretController do
  use NervesHubWeb, :api_controller

  alias NervesHub.AuditLogs
  alias NervesHub.Deployments
  alias NervesHub.Deployments.Deployment
  alias NervesHub.Firmwares

  action_fallback(NervesHubWeb.API.FallbackController)

  plug(:validate_role, [org: :manage] when action in [:create, :update, :delete])
  plug(:validate_role, [org: :view] when action in [:index, :show])

  @whitelist_fields [:name, :org_id, :firmware_id, :conditions, :is_active]

  def index(%{assigns: %{product: product}} = conn, _params) do
    authorized!(:"product:update", conn.assigns.org_user)
    product = Products.load_shared_secret_auth(conn.assigns.product)
    render(conn, "index.json", shared_secrets: product.shared_secret_auths)
  end

  def create(%{assigns: %{org: org, product: product, user: user}} = conn, params) do
    authorized!(:"product:update", conn.assigns.org_user)
    {:ok, shared_secret} = Products.create_shared_secret_auth(conn.assigns.product)

    conn
    |> put_status(:created)
    |> put_resp_header(
      "location",
      Routes.api_deployment_path(conn, :index, org.name, product.name)
    )
    |> render("show.json", shared_secret: shared_secret)
  end

  def delete(%{assigns: %{product: product}} = conn, %{"name" => name}) do
    authorized!(:"product:update", conn.assigns.org_user)
    product = conn.assigns.product
    {:ok, _} = Products.deactivate_shared_secret_auth(product, shared_secret_id)
    send_resp(conn, :no_content, "")
  end
end

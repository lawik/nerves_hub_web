defmodule NervesHubWeb.API.ScriptSchemaTypesTest do
  @moduledoc """
  Reproduction for lawik/nerves_hub_web#6 (upstream PR #2723, commit 2ef75bc1).

  The Support Script OpenAPI response schema declares `tags` as :string and
  `id` as :string, but the API actually returns `tags` as an array of strings
  and `id` as an integer. This test asserts the declared schema types match the
  actual response types, which fails today because of the mistyped schema.

  EXPECTED TO FAIL until the bug is fixed.
  """

  use NervesHubWeb.APIConnCase, async: true

  alias NervesHub.Fixtures
  alias NervesHubWeb.API.Schemas.SupportScriptSchemas.SupportScript
  alias NervesHubWeb.API.Schemas.SupportScriptSchemas.SupportScriptMinimal

  test "show response schema types match the actual API response", %{
    conn: conn,
    org: org,
    product: product,
    user: user
  } do
    script = Fixtures.support_script_fixture(product, user, %{name: "test-script", tags: "cleanup"})

    conn = get(conn, ~p"/api/orgs/#{org.name}/products/#{product.name}/scripts/#{script.id}")

    assert %{"data" => data} = json_response(conn, 200)

    # The actual API returns tags as a list and id as an integer.
    assert is_list(data["tags"]), "expected response tags to be a list, got: #{inspect(data["tags"])}"
    assert is_integer(data["id"]), "expected response id to be an integer, got: #{inspect(data["id"])}"

    # The declared OpenAPI schema must agree with what the API actually returns.
    props = SupportScript.schema().properties

    assert_type(props.tags.type, :array, "SupportScript", "tags", "an array of strings")
    assert_type(props.id.type, :integer, "SupportScript", "id", "an integer")
  end

  test "index (minimal) response schema declares tags and id correctly" do
    props = SupportScriptMinimal.schema().properties

    assert_type(props.tags.type, :array, "SupportScriptMinimal", "tags", "an array of strings")
    assert_type(props.id.type, :integer, "SupportScriptMinimal", "id", "an integer")
  end

  # Helper keeps the actual/expected comparison out of literal-struct inference,
  # avoiding a misleading "disjoint types" compiler warning while keeping the
  # assertion semantics identical.
  defp assert_type(actual, expected, schema, field, actual_description) do
    assert actual == expected,
           "#{schema} schema declares #{field} as #{inspect(actual)}, but the API returns #{actual_description}"
  end
end

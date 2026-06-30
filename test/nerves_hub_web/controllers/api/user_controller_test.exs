defmodule NervesHubWeb.API.UserControllerTest do
  use NervesHubWeb.APIConnCase, async: false

  import PhoenixTest

  alias NervesHub.Fixtures
  alias NervesHub.PlugAttack.Storage, as: PlugAttackStorage
  alias NervesHub.Repo
  alias PlugAttack.Storage.Ets, as: PlugAttackEts

  test "me", %{conn: conn, user: user} do
    conn = get(conn, Routes.api_user_path(conn, :me))

    assert json_response(conn, 200)["data"] == %{
             "name" => user.name,
             "email" => user.email
           }
  end

  test "authenticate existing accounts" do
    password = "1234567891011"

    user =
      Fixtures.user_fixture(%{
        name: "New User",
        email: "account_test@test.com",
        password: password
      })

    conn = build_conn()
    conn = post(conn, Routes.api_user_path(conn, :auth), %{email: user.email, password: password})

    resp = json_response(conn, 200)
    assert resp["data"]["name"] == user.name
    assert resp["data"]["email"] == user.email
    assert "nhu_" <> _ = resp["data"]["token"]
  end

  test "authentication shouldn't blow up if the password isn't included" do
    user =
      Fixtures.user_fixture(%{
        name: "New User",
        email: "account_test@test.com",
        password: "1234567891011"
      })

    conn = build_conn()
    conn = post(conn, Routes.api_user_path(conn, :auth), %{email: user.email})

    assert json_response(conn, 401)["errors"] == %{
             "detail" => "Authentication failed, please check your username and password and try again."
           }
  end

  test "authentication shouldn't blow up if the password is nil" do
    user =
      Fixtures.user_fixture(%{
        name: "New User",
        email: "account_test@test.com",
        password: "1234567891011"
      })

    conn = build_conn()
    conn = post(conn, Routes.api_user_path(conn, :auth), %{email: user.email, password: nil})

    assert json_response(conn, 401)["errors"] == %{
             "detail" => "Authentication failed, please check your username and password and try again."
           }
  end

  test "authentication shouldn't blow up if the password hash is nil" do
    user =
      Fixtures.user_fixture(%{
        name: "New User",
        email: "account_test@test.com",
        password: "1234567891011"
      })

    user = Repo.update!(Ecto.Changeset.change(user, password_hash: nil))

    conn = build_conn()
    conn = post(conn, Routes.api_user_path(conn, :auth), %{email: user.email, password: "1234567891011"})

    assert json_response(conn, 401)["errors"] == %{
             "detail" => "Authentication failed, please check your username and password and try again."
           }
  end

  test "create token for existing account when authenticated" do
    password = "1234567891011"

    user =
      Fixtures.user_fixture(%{
        name: "New User",
        email: "account_test@test.com",
        password: password
      })

    conn = build_conn()

    conn =
      post(conn, Routes.api_user_path(conn, :login), %{
        email: user.email,
        password: password,
        note: "tester"
      })

    resp = json_response(conn, 200)
    assert resp["data"]["name"] == user.name
    assert resp["data"]["email"] == user.email
    assert "nhu_" <> _ = resp["data"]["token"]
  end

  describe "cli session auth exchange" do
    test "created successfully", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/cli_session")

      data = json_response(conn, 200)["data"]

      assert data["token"] =~ ~r/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/
      assert data["url"] =~ "http://localhost:1234/auth/cli/"
    end

    test "checking the status of an uncompleted session returns :waiting", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"
    end

    test "checking the status of a completed session returns :ready and the users auth token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      :ok = NervesHub.Accounts.verify_cli_session_token(user, token)

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "ready"
      assert data["user_token"] =~ "nhu_"
    end

    test "the cli session must be confirmed before it is verified", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/auth/cli_session")

      assert %{"token" => token, "confirmation_code" => _} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      user_token = NervesHub.Accounts.create_user_session_token(user)

      http_conn = build_conn() |> init_test_session(%{"user_token" => user_token})

      http_conn
      |> visit(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "CLI Login")
      |> assert_has("p", text: "Please confirm that the code below matches the code display by the CLI")
      |> click_button("Confirm login")
      |> assert_path(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "You're all set to use the CLI")
    end

    test "a user can refresh the verify token page and still see the success message", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      user_token = NervesHub.Accounts.create_user_session_token(user)

      http_conn = build_conn() |> init_test_session(%{"user_token" => user_token})

      http_conn
      |> visit(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "CLI Login")
      |> assert_has("p", text: "Please confirm that the code below matches the code display by the CLI")
      |> click_button("Confirm login")
      |> assert_path(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "You're all set to use the CLI")

      http_conn
      |> visit(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "You're all set to use the CLI")
    end

    test "a user can refresh the verify token page and still see the success message, but only if they created the token",
         %{conn: conn, user: user, user2: other_user} do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      user_token = NervesHub.Accounts.create_user_session_token(user)

      http_conn = build_conn() |> init_test_session(%{"user_token" => user_token})

      http_conn
      |> visit(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "CLI Login")
      |> assert_has("p", text: "Please confirm that the code below matches the code display by the CLI")
      |> click_button("Confirm login")
      |> assert_path(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "You're all set to use the CLI")

      other_user_token = NervesHub.Accounts.create_user_session_token(other_user)

      http_conn = build_conn() |> init_test_session(%{"user_token" => other_user_token})

      http_conn
      |> visit(~p"/auth/cli/#{token}")
      |> assert_has("h1", text: "CLI authentication failed :(")
    end

    test "a message confirming a failed handshake is shown if the token is not found", %{user: user} do
      user_token = NervesHub.Accounts.create_user_session_token(user)

      http_conn = build_conn() |> init_test_session(%{"user_token" => user_token})

      http_conn
      |> visit(~p"/auth/cli/abc")
      |> assert_has("h1", text: "CLI authentication failed :(")
    end

    test "cannot share the same token", %{conn: conn} do
      Mimic.expect(Ecto.UUID, :generate, 2, fn -> "unique_token" end)

      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]
      assert token =~ "unique_token"

      assert_raise(NervesHubWeb.InvalidRequestError, fn ->
        post(conn, ~p"/api/auth/cli_session")
      end)
    end

    test "cannot verify tokens which are already verified", %{conn: conn, user: user, user2: user2} do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      :ok = NervesHub.Accounts.verify_cli_session_token(user, token)

      assert {:error, :already_verified} = NervesHub.Accounts.verify_cli_session_token(user2, token)
    end

    test "a NervesHubWeb.NotFoundError is raised when a verified tokens status is checked again", %{
      conn: conn,
      user: user
    } do
      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "waiting"

      :ok = NervesHub.Accounts.verify_cli_session_token(user, token)

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      data = json_response(conn, 200)["data"]

      assert data["status"] == "ready"
      assert data["user_token"] =~ "nhu_"

      assert_raise(NervesHubWeb.NotFoundError, fn ->
        get(conn, ~p"/api/auth/cli_session/#{token}")
      end)
    end

    test "rate limits to the check token endpoint", %{conn: conn} do
      on_exit(fn -> PlugAttackEts.clean(PlugAttackStorage) end)

      conn = post(conn, ~p"/api/auth/cli_session")

      token = json_response(conn, 200)["data"]["token"]

      PlugAttackEts.clean(PlugAttackStorage)

      for _ <- 1..30 do
        conn = get(conn, ~p"/api/auth/cli_session/#{token}")
        data = json_response(conn, 200)["data"]

        assert data["status"] == "waiting"
      end

      conn = get(conn, ~p"/api/auth/cli_session/#{token}")
      assert response(conn, 403) =~ "Forbidden"
    end

    # Regression test for lawik/nerves_hub_web#4.
    #
    # The throttle is keyed on the session token, not the client IP. A client
    # cannot escape its per-token limit by rotating its source address or
    # forging X-Forwarded-For: every request for the same token shares one
    # bucket regardless of remote_ip / XFF. Under the previous IP-keyed throttle
    # each spoofed address minted a fresh bucket, so this could never block.
    test "a session token is throttled regardless of source IP or forged X-Forwarded-For",
         %{conn: conn, user_token: user_token} do
      on_exit(fn -> PlugAttackEts.clean(PlugAttackStorage) end)

      conn = post(conn, ~p"/api/auth/cli_session")
      token = json_response(conn, 200)["data"]["token"]

      PlugAttackEts.clean(PlugAttackStorage)

      # Each poll arrives from a different remote_ip AND a different (forged)
      # X-Forwarded-For, as an attacker rotating addresses would send.
      poll = fn n ->
        build_auth_conn(user_token)
        |> Map.put(:remote_ip, {10, 0, 0, n})
        |> put_req_header("x-forwarded-for", "203.0.113.#{n}")
        |> get(~p"/api/auth/cli_session/#{token}")
      end

      for n <- 1..30 do
        assert json_response(poll.(n), 200)["data"]["status"] == "waiting"
      end

      # The 31st request for the same token is blocked even though it comes from
      # a brand new IP / XFF the throttle has never seen.
      assert response(poll.(31), 403) =~ "Forbidden"
    end

    test "distinct session tokens are throttled independently", %{conn: conn} do
      on_exit(fn -> PlugAttackEts.clean(PlugAttackStorage) end)

      token_a = json_response(post(conn, ~p"/api/auth/cli_session"), 200)["data"]["token"]
      token_b = json_response(post(conn, ~p"/api/auth/cli_session"), 200)["data"]["token"]

      PlugAttackEts.clean(PlugAttackStorage)

      for _ <- 1..30 do
        assert json_response(get(conn, ~p"/api/auth/cli_session/#{token_a}"), 200)["data"]["status"] ==
                 "waiting"
      end

      # Token A is exhausted, but token B has its own bucket and is unaffected.
      assert response(get(conn, ~p"/api/auth/cli_session/#{token_a}"), 403) =~ "Forbidden"

      assert json_response(get(conn, ~p"/api/auth/cli_session/#{token_b}"), 200)["data"]["status"] ==
               "waiting"
    end

    test "a global limit backstops total request volume across tokens" do
      on_exit(fn -> PlugAttackEts.clean(PlugAttackStorage) end)
      PlugAttackEts.clean(PlugAttackStorage)

      # The global bucket ignores the token. Pin the time so every call lands in
      # one period window and skips the cross-node broadcast.
      now = System.system_time(:millisecond)

      for n <- 1..1000 do
        assert NervesHubWeb.Plugs.Attack.global_throttle(time: now) == nil,
               "request #{n} should be under the global limit"
      end

      assert {:block, _} = NervesHubWeb.Plugs.Attack.global_throttle(time: now)
    end
  end
end

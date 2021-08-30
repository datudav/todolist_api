defmodule ToDoListAppWeb.UserControllerTest do
  use ToDoListAppWeb.ConnCase

  alias ToDoListApp.Account
  alias ToDoListApp.Account.User

  @create_attrs %{
    email: "some@email.com",
    password: "some password"
  }
  @create_attrs2 %{
    email: "some2@email.com",
    password: "some2 password"
  }
  @update_attrs %{
    email: "some.updated@email.com",
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Account.register_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "successful", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      assert %{
                "user_id" => user_id,
                "email" => "some@email.com"
              } = json_response(conn, 201)["data"]["user"]
    end

    test "renders error when the request passed is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @invalid_attrs)

      assert %{
                "detail" => "Email is required."
              } = json_response(conn, 422)["errors"]
    end

    test "renders error when the email is already taken", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)

      assert %{
                "detail" => "The email is already taken."
              } = json_response(conn, 422)["errors"]
    end
  end

  describe "sign in" do
    test "successful", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password:  @create_attrs[:password])

      assert %{
        "user_id" => user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]

      conn = get(conn, Routes.api_v1_user_path(conn, :show, user_id))

      assert %{
        "user_id" => _user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]
    end

    test "renders error when the credentials are invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password: "invalid password")

      assert %{
        "detail" => "Invalid credentials"
      } = json_response(conn, 401)["errors"]
    end

    test "renders errors when the user is not authenticated", %{conn: conn} do
      conn = get(conn, Routes.api_v1_user_path(conn, :index))

      assert %{
        "detail" => "Unauthenticated user"
      } = json_response(conn, 401)["errors"]
    end
  end

  describe "update user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password:  @create_attrs[:password])

      assert %{
        "user_id" => user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]

      conn = patch(conn, Routes.api_v1_user_path(conn, :update, user_id), user: @update_attrs)
      assert %{"user_id" => user_id} = json_response(conn, 200)["data"]["user"]
      conn = get(conn, Routes.api_v1_user_path(conn, :show, user_id))

      assert %{
               "user_id" => _user_id,
               "email" => "some.updated@email.com"
             } = json_response(conn, 200)["data"]["user"]
    end

    test "renders error when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password:  @create_attrs[:password])

      assert %{
        "user_id" => user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]

      conn = patch(conn, Routes.api_v1_user_path(conn, :update, user_id), user: @invalid_attrs)

      assert %{
        "detail" => "Email is required."
      } = json_response(conn, 422)["errors"]

      conn = get(conn, Routes.api_v1_user_path(conn, :show, user_id))

      assert %{
               "user_id" => _user_id,
               "email" => "some@email.com"
             } = json_response(conn, 200)["data"]["user"]
    end
  end


  describe "delete user" do
    test "deletes chosen user", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password:  @create_attrs[:password])

      assert %{
        "user_id" => user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]

      conn = delete(conn, Routes.api_v1_user_path(conn, :delete, user_id))
      assert response(conn, 204)

      conn = get(conn, Routes.api_v1_user_path(conn, :show, user_id))
      assert response(conn, 404)
    end
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs)
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_attrs2)
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_attrs[:email], password:  @create_attrs[:password])

      assert %{
        "user_id" => user_id,
        "email" => "some@email.com"
      } = json_response(conn, 200)["data"]["user"]

      conn = get(conn, Routes.api_v1_user_path(conn, :index))

      assert Enum.count(json_response(conn, 200)["data"]) == 2
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end

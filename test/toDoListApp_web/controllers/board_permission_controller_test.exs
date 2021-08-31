defmodule ToDoListAppWeb.BoardPermissionControllerTest do
  use ToDoListAppWeb.ConnCase

  alias ToDoListApp.Account

  @create_user_attrs %{
    "email" => "some@email.com",
    "password" => "some password"
  }

  @create_user_attrs2 %{
    "email" => "some2@email.com",
    "password" => "some2 password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def fixture(:user) do
    {:ok, user} = Account.register_user(@create_user_attrs)
    user
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end


  describe "index" do
    setup [:create_user]

    test "list board permissions", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => owner_id,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :index, board_id))

      assert %{
        "board_permission_id" => _,
        "board_id" => _,
        "user_id" => user_id,
        "permission_type" => permission_type
      } = Enum.at(json_response(conn, 200)["data"], 0)["board_permission"]

      assert user_id === owner_id && permission_type === "manage"
    end

    test "render errors when passed board_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :index, Ecto.UUID.generate))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end

  describe "show" do
    setup [:create_user]

    test "render board permission", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :index, board_id))

      %{
        "board_permission_id" => board_permission_id,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board_permission"]

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :show, board_id, board_permission_id))

      assert %{
        "board_permission_id" => _,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => _
      } = json_response(conn, 200)["data"]["board_permission"]
    end

    test "render errors when passed board_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :show, Ecto.UUID.generate, Ecto.UUID.generate))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end

  describe "create" do
    setup [:create_user]

    test "render created board permission", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => user2_id
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_board_permission_path(conn, :create, board_id),
        board_permission: %{"board_id" => board_id, "user_id" => user2_id, "permission_type" => "write"})

      assert %{
        "board_permission_id" => _,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => permission_type
      } = json_response(conn, 201)["data"]["board_permission"]

      assert permission_type === "write"

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :index, board_id))

      assert Enum.count(json_response(conn, 200)["data"]) === 2
    end

    test "render errors when creating board permission with incomplete details", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => _
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_board_permission_path(conn, :create, board_id),
        board_permission: %{"board_id" => nil, "user_id" => nil, "permission_type" => nil})

      assert %{"detail" => _} = json_response(conn, 422)["errors"]
    end
  end




  describe "delete" do
    setup [:create_user]

    test "no response on delete board permission", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => user2_id
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_board_permission_path(conn, :create, board_id),
        board_permission: %{"board_id" => board_id, "user_id" => user2_id, "permission_type" => "write"})

      %{
        "board_permission_id" => board_permission_id,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => _
      } = json_response(conn, 201)["data"]["board_permission"]

      conn = delete(conn, Routes.api_v1_board_board_permission_path(conn, :delete, board_id, board_permission_id))
      assert response(conn, 204)

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :show, board_id, board_permission_id))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end

    test "render errors when board_permission_id does not exist", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => _
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = delete(conn, Routes.api_v1_board_board_permission_path(conn, :delete, Ecto.UUID.generate, Ecto.UUID.generate))
      assert response(conn, 404)
    end
  end


  describe "update" do
    setup [:create_user]

    test "render board permission", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => user2_id
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_board_permission_path(conn, :create, board_id),
        board_permission: %{"board_id" => board_id, "user_id" => user2_id, "permission_type" => "write"})

      %{
        "board_permission_id" => board_permission_id,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => "write"
      } = json_response(conn, 201)["data"]["board_permission"]

      conn = patch(conn, Routes.api_v1_board_board_permission_path(conn, :update, board_id, board_permission_id), board_permission: %{"permission_type" => "read"})
      assert %{
        "board_permission_id" => _,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => "read"
      } = json_response(conn, 200)["data"]["board_permission"]

      conn = get(conn, Routes.api_v1_board_board_permission_path(conn, :show, board_id, board_permission_id))

      assert %{
        "board_permission_id" => _,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => "read"
      } = json_response(conn, 200)["data"]["board_permission"]
    end

    test "render errors when permission_type is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :register), user: @create_user_attrs2)
      %{
        "user_id" => user2_id
      } = json_response(conn, 201)["data"]["user"]

      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)["board"]

      conn = post(conn, Routes.api_v1_board_board_permission_path(conn, :create, board_id),
        board_permission: %{"board_id" => board_id, "user_id" => user2_id, "permission_type" => "write"})

      %{
        "board_permission_id" => board_permission_id,
        "board_id" => _,
        "user_id" => _,
        "permission_type" => "write"
      } = json_response(conn, 201)["data"]["board_permission"]

      conn = patch(conn, Routes.api_v1_board_board_permission_path(conn, :update, board_id, board_permission_id), board_permission: %{"permission_type" => "owner"})

      assert %{
        "detail" => "Permission_type provided is invalid."
      } = json_response(conn, 422)["errors"]
    end
  end
end

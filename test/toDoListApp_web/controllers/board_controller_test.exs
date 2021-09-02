defmodule ToDoListAppWeb.BoardControllerTest do
  use ToDoListAppWeb.ConnCase

  alias ToDoListApp.Account
  alias ToDoListApp.Account.User

  @create_user_attrs %{
    "email" => "some@email.com",
    "password" => "some password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def fixture(:user) do
    {:ok, user} = Account.register_user(@create_user_attrs)
    user
  end

  def fixture(:sign_in, conn) do
    conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
    json_response(conn, 200)["data"]
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

  defp sign_in_user(%{conn: conn}) do
    user = fixture(:sign_in, conn)
    %{user: user}
  end

  describe "index" do
    setup [:create_user]

    test "list boards", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index))
      assert %{
        "owner_id" => _,
        "board_id" => _,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      assert Enum.count(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "show by owner_id" do
    setup [:create_user]

    test "render board", %{conn: conn, user: %User{} = user} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index, params: %{owner_id: user.user_id}))

      assert %{
        "owner_id" => _,
        "board_id" => _,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)
    end

    test "render errors when the owner_id is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index, params: %{owner_id: Ecto.UUID.generate}))
      assert response(conn, 200)

      assert Enum.count(json_response(conn, 200)["data"]) === 0
    end
  end

  describe "show" do
    setup [:create_user]

    test "render board", %{conn: conn, user: %User{} = user} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index, params: %{owner_id: user.user_id}))

      assert %{
        "owner_id" => _,
        "board_id" => board_id,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = get(conn, Routes.api_v1_board_path(conn, :show, board_id))
      assert %{
        "owner_id" => _,
        "board_id" => _board_id,
        "title" => _,
        "description" => _
      } = json_response(conn, 200)["data"]
    end

    test "render errors when the board_id is invalid", %{conn: conn, user: %User{} = user} do
      conn = post(conn, Routes.api_v1_user_path(conn, :sign_in), email: @create_user_attrs["email"], password: @create_user_attrs["password"])
      conn = get(conn, Routes.api_v1_board_path(conn, :index, params: %{owner_id: user.user_id}))

      assert %{
        "owner_id" => _,
        "board_id" => _,
        "title" => _,
        "description" => _
      } = Enum.at(json_response(conn, 200)["data"], 0)

      conn = get(conn, Routes.api_v1_board_path(conn, :show, Ecto.UUID.generate()))

      assert %{
        "detail" => "Resource not found"
      } = json_response(conn, 404)["errors"]
    end
  end
end

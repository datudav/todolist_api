defmodule ToDoListAppWeb.Api.V1.BoardPermissionController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.Account
  alias ToDoListApp.Account.BoardPermission

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"board_permission_id" => board_permission_id}) do
    board_permissions = Account.get_board_permission(board_permission_id)
    render(conn, "index.json", board_permissions: board_permissions)
  end

  def create(conn, %{"board_permission" => board_permission_params}) do
    with {:ok, %BoardPermission{} = board_permission} <- Account.create_board_permission(board_permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_board_board_permission_path(conn, :show, board_permission))
      |> render("show.json", board_permission: board_permission)
    end
  end

  def show(conn, %{"id" => id}) do
    board_permission = Account.get_board_permission(id)
    render(conn, "show.json", board_permission: board_permission)
  end

  def update(conn, %{"id" => id, "board_permission" => board_permission_params}) do
    board_permission = Account.get_board_permission(id)

    with {:ok, %BoardPermission{} = board_permission} <- Account.update_board_permission(board_permission, board_permission_params) do
      render(conn, "show.json", board_permission: board_permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    board_permission = Account.get_board_permission(id)

    with {:ok, %BoardPermission{}} <- Account.delete_board_permission(board_permission) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule ToDoListAppWeb.Api.V1.BoardPermissionController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext
  alias ToDoListApp.BoardContext.BoardPermission

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, params) do
    with {:ok, board_permissions} <- {:ok, BoardContext.list_board_permissions(Map.get(params, "params"))} do
      conn
      |> put_status(:ok)
      |> render("index.json", board_permissions: board_permissions)
    else
      err ->
      conn
        |> put_status(:unprocessable_entity)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("422.json", message: err)
    end
  end

  def create(conn, %{"board_permission" => board_permission_params}) do
    with {:ok, %BoardPermission{} = board_permission} <- BoardContext.create_board_permission(board_permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_v1_board_permission_path(conn, :show, board_permission.board_permission_id))
      |> render("show.json", board_permission: board_permission)
    else
      {:error, message} ->
      conn
        |> put_status(:unprocessable_entity)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("422.json", message: message)
    end
  end

  def show(conn, %{"id" => board_permission_id}) do
    case BoardContext.get_board_permission(board_permission_id) do
      {:ok, board_permission} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.BoardPermissionView)
        |> render("show.json", board_permission: board_permission)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def update(conn, %{"id" => board_permission_id, "board_permission" => board_permission_params}) do
    case BoardContext.get_board_permission(board_permission_id) do
      {:ok, board_permission} ->
        case BoardContext.update_board_permission(board_permission, board_permission_params) do
          {:ok, board_permission} ->
            conn
            |> put_status(:ok)
            |> put_view(ToDoListAppWeb.Api.V1.BoardPermissionView)
            |> render("show.json", board_permission: board_permission)
          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: message)
      end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def delete(conn, %{"id" => board_permission_id}) do
    case BoardContext.get_board_permission(board_permission_id) do
      {:ok, board_permission} ->
        case BoardContext.delete_board_permission(board_permission) do
          {:ok, _} ->
            conn
            |> put_status(:no_content)
            |> send_resp(204, "")
          {:error, message} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: message)
        end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end
end

defmodule ToDoListAppWeb.Api.V1.ListController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext
  alias ToDoListApp.ListContext
  alias ToDoListApp.ListContext.List

  def index(conn, %{"board_id" => board_id}) do
    case BoardContext.get_board!(board_id) do
      {:ok, _board} ->
        with {:ok, lists} <- {:ok, ListContext.list_lists(board_id)} do
          conn
          |> put_status(:ok)
          |> render("index.json", lists: lists)
        else
          err ->
          conn
            |> put_status(:unprocessable_entity)
            |> put_view(ToDoListAppWeb.ErrorView)
            |> render("422.json", message: err)
        end
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def show(conn, %{"id" => list_id}) do
    case ListContext.get_list!(list_id) do
      {:ok, list} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.ListView)
        |> render("show.json", list: list)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def create(conn, %{"board_id" => board_id, "list" => list_params}) do
    case BoardContext.get_board!(board_id) do
      {:ok, _board} ->
        with {:ok, %List{} = list} <- ListContext.create_list(list_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.api_v1_board_list_path(conn, :show, list.board_id, list.list_id))
          |> render("show.json", list: list)
        else
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

  def update(conn, %{"id" => list_id, "list" => list_params}) do
    case ListContext.get_list!(list_id) do
      {:ok, list} ->
        case ListContext.update_list(list, list_params) do
          {:ok, list} ->
            conn
            |> put_status(:ok)
            |> put_view(ToDoListAppWeb.Api.V1.ListView)
            |> render("show.json", list: list)
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

  def delete(conn, %{"id" => list_id}) do
    case ListContext.get_list!(list_id) do
      {:ok, list} ->
        case ListContext.delete_list(list) do
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

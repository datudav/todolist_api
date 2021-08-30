defmodule ToDoListAppWeb.Api.V1.BoardController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, _params) do
    boards = BoardContext.list_board()
    render(conn, "index.json", boards: boards)
  end

  def show(conn, %{"id" => board_id}) do
    case BoardContext.get_board!(board_id) do
      {:ok, board} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.BoardView)
        |> render("show.json", board: board)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

  def show_by_user(conn, %{"owner_id" => owner_id}) do
    case BoardContext.get_board_by_owner_id!(owner_id) do
      {:ok, board} ->
        conn
        |> put_status(:ok)
        |> put_view(ToDoListAppWeb.Api.V1.BoardView)
        |> render("show.json", board: board)
      {:error, message} ->
        conn
        |> put_status(:not_found)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("404.json", message: message)
    end
  end

end

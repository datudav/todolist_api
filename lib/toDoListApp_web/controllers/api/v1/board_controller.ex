defmodule ToDoListAppWeb.Api.V1.BoardController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, params) do
    with {:ok, boards} <- {:ok, BoardContext.list_boards(Map.get(params, "params"))} do
      conn
      |> put_status(:ok)
      |> render("index.json", boards: boards)
    else
      err ->
      conn
        |> put_status(:unprocessable_entity)
        |> put_view(ToDoListAppWeb.ErrorView)
        |> render("422.json", message: err)
    end
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
end

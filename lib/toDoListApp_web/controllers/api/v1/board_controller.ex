defmodule ToDoListAppWeb.Api.V1.BoardController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, _params) do
    boards = BoardContext.list_board()
    render(conn, "index.json", boards: boards)
  end

  def show(conn, %{"board_id" => board_id}) do
    board = BoardContext.get_board!(board_id)
    render(conn, "index.json", board: board)
  end

  def show_by_user(conn, %{"owner_id" => owner_id}) do
    board = BoardContext.get_board_by_owner_id(owner_id)
    render(conn, "index.json", board: board)
  end

end

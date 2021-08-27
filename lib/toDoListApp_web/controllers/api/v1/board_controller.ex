defmodule ToDoListAppWeb.Api.V1.BoardController do
  use ToDoListAppWeb, :controller

  alias ToDoListApp.BoardContext

  action_fallback ToDoListAppWeb.FallbackController

  def index(conn, %{"owner_id" => owner_id}) do
    board = BoardContext.list_board(owner_id)
    render(conn, "index.json", board: board)
  end
end

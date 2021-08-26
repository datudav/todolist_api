defmodule ToDoListAppWeb.Api.V1.BoardView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.BoardView

  def render("index.json", %{board: board}) do
    %{data: render_one(board, BoardView, "board.json")}
  end

  def render("board.json", %{board: board}) do
    %{id: board.board_id,
      title: board.title,
      description: board.description,
      owner_id: board.owner_id}
  end
end

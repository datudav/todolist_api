defmodule ToDoListAppWeb.Api.V1.BoardView do
  use ToDoListAppWeb, :view
  alias ToDoListAppWeb.Api.V1.BoardView

  def render("index.json", %{boards: boards}) do
    %{data: render_many(boards, BoardView, "board.json")}
  end

  def render("show.json", %{board: board}) do
    %{data: render_one(board, BoardView, "board.json")}
  end

  def render("board.json", %{board: board}) do
    %{
        board: %{
          board_id: board.board_id,
          title: board.title,
          description: board.description,
          owner_id: board.owner_id
        }
      }
  end
end

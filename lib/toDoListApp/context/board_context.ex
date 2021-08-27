defmodule ToDoListApp.BoardContext do
  import Ecto.Query
  alias ToDoListApp.Repo
  alias ToDoListApp.BoardContext.Board

  def list_board(owner_id) do
    Repo.all(from b in Board,
            where: b.owner_id == ^owner_id,
            order_by: [asc: b.inserted_at])
  end

  def get_board!(board_id), do: Repo.get!(Board, board_id)

  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end
end

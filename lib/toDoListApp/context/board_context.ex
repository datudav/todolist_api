defmodule ToDoListApp.BoardContext do

  alias ToDoListApp.Repo
  alias ToDoListApp.BoardContext.Board


  def list_board() do
    Repo.all(Board)
  end

  def get_board_by_owner_id!(owner_id) do
    case board = Repo.get_by(Board, owner_id: owner_id) do
      nil -> {:error, "The board with the owner_id provided does not exist."}
      _ -> {:ok, board}
    end
  end

  def get_board!(board_id) do
    case board = Repo.get_by(Board, board_id: board_id) do
      nil -> {:error, "The board does not exist."}
      _ -> {:ok, board}
    end
  end

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

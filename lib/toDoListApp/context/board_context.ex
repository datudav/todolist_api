defmodule ToDoListApp.BoardContext do
  import Ecto.Query
  alias ToDoListApp.Repo
  alias ToDoListApp.BoardContext.Board
  alias ToDoListApp.BoardContext.BoardPermission

  def list_boards(params) do
    query = from b in Board
    query
    |> board_build_query(params)
    |> Repo.all()
  end

  def board_build_query(query, params) do
    params["owner_id"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(owner_id: ^text)
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

  # def list_board_permission(board_id) do
  #   Repo.all(from b in BoardPermission,
  #           where: b.board_id == ^board_id)
  # end

  def list_board_permissions(params) do
    query = from b in BoardPermission
    query
    |> board_permission_build_query(params)
    |> Repo.all()
  end

  def board_permission_build_query(query, params) do
    params["user_id"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(user_id: ^text)
    end

    params["board_id"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(board_id: ^text)
    end
  end

  def create_board_permission(attrs \\ %{}) do
    with {:ok, "Validation passed"} <- validate_board_permission(attrs) do
      %BoardPermission{}
      |> BoardPermission.changeset(attrs)
      |> Repo.insert()
    else
      err -> err
    end
  end

  def get_board_permission(board_permission_id) do
    case board_permission = Repo.get_by(BoardPermission, board_permission_id: board_permission_id) do
      nil -> {:error, "The board permission does not exist."}
      %BoardPermission{} -> {:ok, board_permission}
    end
  end

  def update_board_permission(%BoardPermission{} = board_permission, attrs) do
    with {:ok, "Validation passed"} <- validate_board_permission(attrs),
        {:ok, valid_attrs} <- Map.fetch(attrs, "permission_type") do
      board_permission
      |> BoardPermission.changeset(%{"permission_type" => valid_attrs})
      |> Repo.update()
    else
      err -> err
    end
  end

  def delete_board_permission(%BoardPermission{} = board_permission) do
    Repo.delete(board_permission)
  end

  def check_user_permission(board_id, user_id) do
    case board_permission = Repo.get_by(BoardPermission, board_id: board_id, user_id: user_id) do
      nil -> {:error, "The user does not have permission to perform the operation."}
      _ -> {:ok, board_permission}
    end
  end

  defp validate_board_permission(board_permission_params) do
    case board_permission_params do
      %{"board_id" => nil} -> {:error, "Board_id is required."}
      %{"user_id" => nil} -> {:error, "User_id is required."}
      %{"permission_type" => nil} -> {:error, "Permission_type is required"}
      %{"permission_type" => permission_type} ->
        if Enum.member?(["manage", "write", "read"], permission_type) do
          {:ok, "Validation passed"}
        else
          {:error, "Permission_type provided is invalid."}
        end
      _ -> {:ok, "Validation passed"}
    end
  end

end

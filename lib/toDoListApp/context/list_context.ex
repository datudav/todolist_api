defmodule ToDoListApp.ListContext do

  import Ecto.Query
  alias ToDoListApp.Repo
  alias ToDoListApp.ListContext.List

  def list_lists(board_id) do
    Repo.all(from l in List,
            where: l.board_id == ^board_id,
            order_by: [asc: l.inserted_at])
  end

  def get_list(list_id), do: Repo.get(List, list_id)

  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end
end

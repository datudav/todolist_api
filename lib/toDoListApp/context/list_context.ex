defmodule ToDoListApp.ListContext do

  import Ecto.Query
  alias ToDoListApp.Repo
  alias ToDoListApp.ListContext.List

  def list_lists(params) do
    query = from l in List
    Repo.all(list_build_query(query, params))
  end

  def list_build_query(query, params) do
    params["board_id"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(board_id: ^text)
    end

    params["creator_id"]
    |> case do
      nil -> query
      "" -> query
      text -> query |> where(creator_id: ^text)
    end
  end

  def get_list!(list_id) do
    case list = Repo.get_by(List, list_id: list_id) do
      nil -> {:error, "The list does not exist"}
      _ -> {:ok, list}
    end
  end

  def create_list(attrs \\ %{}) do
    with {:ok, "Validation passed"} <- validate_list(attrs) do
      %List{}
      |> List.changeset(attrs)
      |> Repo.insert()
    else
      {:error, message} -> {:error, message}
    end
  end

  def update_list(%List{} = list, attrs) do
    with {:ok, "Validation passed"} <- validate_list(attrs) do
      list
      |> List.changeset(attrs)
      |> Repo.update()
    else
      {:error, message} -> {:error, message}
    end
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  defp validate_list(list_params) do
    case list_params do
      %{"title" => nil} -> {:error, "Title is required."}
      %{"description" => nil} -> {:error, "Description is required."}
      %{"board_id" => nil} -> {:error, "Board_id is required"}
      %{"creator_id" => nil} -> {:error, "Creator_id is required"}
      _ -> {:ok, "Validation passed"}
    end
  end

end

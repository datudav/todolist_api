defmodule ToDoListApp.TaskContext do
  @moduledoc """
  The TaskContext context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias ToDoListApp.Repo

  alias ToDoListApp.TaskContext.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    query = from t in Task,
          order_by: [asc: t.rank]
    Repo.all(query)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> set_unix_epoch
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def rank_up(%Task{} = task) do
    query = from t in Task,
      select: t.rank,
      where: t.rank < ^task.rank,
      order_by: [desc: t.rank],
      limit: 2
      ranks = Repo.all(query)
      new_rank = Decimal.div(Decimal.add(Enum.at(ranks, 0), Enum.at(ranks, 1)), 2)
      update_task(task, %{rank: new_rank})
  end

  def rank_down(%Task{} = task) do
    query = from t in Task,
      select: t.rank,
      where: t.rank > ^task.rank,
      order_by: [asc: t.rank],
      limit: 2
      ranks = Repo.all(query)
      new_rank = Decimal.div(Decimal.add(Enum.at(ranks, 0), Enum.at(ranks, 1)), 2)
      update_task(task, %{rank: new_rank})
  end

  defp set_unix_epoch(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{}} ->
        put_change(changeset, :rank, get_unix_epoch())
        _ ->
        changeset
    end
  end

  defp get_unix_epoch do
    :calendar.universal_time()
    |> :calendar.datetime_to_gregorian_seconds()
    |> Kernel.-(62167219200)
  end
end

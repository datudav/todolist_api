defmodule ToDoListApp.TaskContext do
  @moduledoc """
  The TaskContext context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias ToDoListApp.Repo
  alias ToDoListApp.TaskContext.Task
  alias ToDoListApp.TaskContext.TaskComment

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks(list_id) do
    Repo.all(from t in Task,
            where: t.list_id == ^list_id,
            order_by: [asc: t.rank])
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
  def get_task!(task_id) do
    case task = Repo.get_by(Task, task_id: task_id) do
      nil -> {:error, "The task does not exist"}
      _ -> {:ok, task}
    end
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    with {:ok, "Validation passed"} <- validate_task(attrs) do
      %Task{}
      |> Task.changeset(attrs)
      |> set_unix_epoch
      |> Repo.insert()
    else
      {:error, message} -> {:error, message}
    end
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
    with {:ok, "Validation passed"} <- validate_task(attrs) do
      task
      |> Task.changeset(attrs)
      |> Repo.update()
    else
      {:error, message} -> {:error, message}
    end
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

  @doc """
  Returns the list of task comments by task_id.

  ## Examples

      iex> list_task_comments()
      [%Task{}, ...]

  """
  def list_task_comments(task_id) do
    Repo.all(from t in TaskComment,
      where: t.task_id == ^task_id,
      order_by: [asc: t.inserted_at])
  end

  @doc """
  Gets a single task comment.

  Raises `Ecto.NoResultsError` if the Task Comment does not exist.

  ## Examples

      iex> get_task_comment!(123)
      %Task{}

      iex> get_task_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task_comment!(task_comment_id) do
    case task_comment = Repo.get_by!(TaskComment, tasks_comment_id: task_comment_id) do
      nil -> {:error, "The task comment does not exist."}
      _ -> {:ok, task_comment}
    end
  end

  @doc """
  Creates a task comment.

  ## Examples

      iex> create_task_comment(%{field: value})
      {:ok, %Task{}}

      iex> create_task_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task_comment(attrs \\ %{}) do
    with {:ok, "Validation passed"} <- validate_task_comment(attrs) do
      %TaskComment{}
      |> TaskComment.changeset(attrs)
      |> Repo.insert()
    else
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Updates a task comment.

  ## Examples

      iex> update_task_comment(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task_comment(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task_comment(%TaskComment{} = task_comment, attrs) do
    with {:ok, "Validation passed"} <- validate_task_comment(attrs) do
      task_comment
      |> TaskComment.changeset(attrs)
      |> Repo.update()
    else
      {:error, message} -> {:error, message}
    end
  end

    @doc """
  Deletes a task comment.

  ## Examples

      iex> delete_task_comment(task_comment)
      {:ok, %Task{}}

      iex> delete_task_comment(task_comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task_comment(%TaskComment{} = task_comment) do
    Repo.delete(task_comment)
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

  defp validate_task(task_params) do
    case task_params do
      %{"title" => nil} -> {:error, "Title is required."}
      %{"description" => nil} -> {:error, "Description is required."}
      %{"list_id" => nil} -> {:error, "Board_id is required"}
      _ -> {:ok, "Validation passed"}
    end
  end


  defp validate_task_comment(task_comment_params) do
    case task_comment_params do
      %{"comments" => nil} -> {:error, "Comments is required."}
      %{"creator_id" => nil} -> {:error, "Creator_id is required."}
      %{"task_id" => nil} -> {:error, "Task_id is required"}
      _ -> {:ok, "Validation passed"}
    end
  end
end

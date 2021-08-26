defmodule ToDoListApp.TaskContext.TaskComment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ToDoListApp.TaskContext.TaskComment

  @primary_key {:task_comment_id, :binary_id, autogenerate: true}
  schema "task_comment" do
    field :comments, :string
    field :task_id, Ecto.UUID
    field :creator_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(%TaskComment{} = task_comment, attrs) do
    task_comment
    |> cast(attrs, [:comments, :task_id, :creator_id])
    |> validate_required([:comments, :task_id, :creator_id])
  end
end

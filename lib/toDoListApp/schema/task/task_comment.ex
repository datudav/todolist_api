defmodule ToDoListApp.TaskContext.TaskComment do
  use Ecto.Schema
  import Ecto.Changeset
  alias ToDoListApp.TaskContext.TaskComment

  @primary_key {:task_comment_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task_comment" do
    field :comments, :string

    belongs_to(:task, ToDoListApp.TaskContext.Task, references: :task_id)
    belongs_to(:creator, ToDoListApp.Account.User, references: :user_id)

    timestamps()
  end

  @doc false
  def changeset(%TaskComment{} = task_comment, attrs) do
    task_comment
    |> cast(attrs, [:comments])
    |> validate_required([:comments])
  end
end

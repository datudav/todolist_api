defmodule ToDoListApp.TaskContext.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias ToDoListApp.TaskContext.Task

  @primary_key {:task_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "task" do
    field :description, :string
    field :title, :string
    field :rank, :decimal

    belongs_to(:list, ToDoListApp.ListContext.List, references: :list_id)
    has_many(:task_comment, ToDoListApp.TaskContext.TaskComment, foreign_key: :task_id)

    timestamps()
  end

  @doc false
  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [:title, :description, :rank])
    |> validate_required([:title, :description])
  end
end

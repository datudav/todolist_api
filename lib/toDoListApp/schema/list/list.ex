defmodule ToDoListApp.ListContext.List do
  use Ecto.Schema
  import Ecto.Changeset
  alias ToDoListApp.ListContext.List

  @primary_key {:list_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lists" do
    field :title, :string
    field :description, :string

    belongs_to(:board, ToDoListApp.BoardContext.Board, references: :board_id)

    has_many(:tasks, ToDoListApp.TaskContext.Task, foreign_key: :task_id)

    timestamps()
  end

  @doc false
  def changeset(%List{} = list, attrs) do
    list
    |> cast(attrs, [:title, :description, :board_id])
    |> validate_required([:title, :description, :board_id])
  end
end

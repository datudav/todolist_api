defmodule ToDoListApp.BoardContext.Board do
  use Ecto.Schema
  import Ecto.Changeset
  alias ToDoListApp.BoardContext.Board

  @primary_key {:board_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "board" do
    field(:title, :string)
    field(:description, :string)

    belongs_to(:owner, ToDoListApp.Account.User, references: :user_id)
    has_many(:lists, ToDoListApp.ListContext.List, foreign_key: :list_id)

    timestamps()
  end

  @doc false
  def changeset(%Board{} = board, attrs) do
    board
    |> cast(attrs, [:title, :description, :owner_id])
    |> validate_required([:title, :description, :owner_id])
  end
end

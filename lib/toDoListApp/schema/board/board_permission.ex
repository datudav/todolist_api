defmodule ToDoListApp.BoardContext.BoardPermission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:board_permission_id, :binary_id, autogenerate: true}
  schema "board_permission" do
    field :board_id, Ecto.UUID, null: false
    field :user_id, Ecto.UUID, null: false
    field :permission_type, Ecto.Enum, values: [:manage, :write, :read]

    timestamps()
  end

  @doc false
  def changeset(board_permission, attrs) do
    board_permission
    |> cast(attrs, [:board_id, :user_id, :permission_type])
    |> validate_required([:board_id, :user_id, :permission_type])
  end
end

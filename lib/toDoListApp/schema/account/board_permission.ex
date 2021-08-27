defmodule ToDoListApp.Account.BoardPermission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:board_permission_id, :binary_id, autogenerate: true}
  schema "board_permission" do
    field :board_id, Ecto.UUID, null: false
    field :permission_id, Ecto.UUID, null: false
    field :user_id, Ecto.UUID, null: false

    timestamps()
  end

  @doc false
  def changeset(board_permission, attrs) do
    board_permission
    |> cast(attrs, [:board_id, :permission_id, :user_id])
    |> validate_required([:board_id, :permission_id, :user_id])
  end
end

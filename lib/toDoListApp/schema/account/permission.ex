defmodule ToDoListApp.Account.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:permission_id, :binary_id, autogenerate: true}
  schema "permission" do
    field :description, :string, null: false
    field :board_permission_id, Ecto.UUID, null: false

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end

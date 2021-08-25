defmodule ToDoListApp.Repo.Migrations.CreateBoard do
  use Ecto.Migration

  def change do
    create table(:board, primary_key: false) do
      add :board_id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :title, :text, null: false
      add :description, :text, null: false
      add :owner_id, references(:users, column: :id, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end

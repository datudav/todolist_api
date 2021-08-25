defmodule ToDoListApp.Repo.Migrations.CreateList do
  use Ecto.Migration

  def change do
    create table(:list, primary_key: false) do
      add :list_id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :title, :text, null: false
      add :description, :text, null: false
      add :board_id, references(:board, column: :board_id, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end

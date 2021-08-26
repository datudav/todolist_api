defmodule ToDoListApp.Repo.Migrations.CreateBoardPermission do
  use Ecto.Migration

  def change do
    create table(:board_permission, primary_key: false) do
      add :board_permission_id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :board_id, references(:board, column: :board_id, type: :uuid, on_delete: :delete_all), null: false
      add :permission_id, references(:permission, column: :permission_id, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, column: :user_id, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end

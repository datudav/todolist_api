defmodule ToDoListApp.Repo.Migrations.UpdateBoardPermission do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE board_permission DROP CONSTRAINT board_permission_permission_id_fkey;"
    execute "ALTER TABLE board_permission DROP COLUMN permission_id;"

    alter table(:board_permission) do
      add :permission_type, :string, null: false
    end
  end
end

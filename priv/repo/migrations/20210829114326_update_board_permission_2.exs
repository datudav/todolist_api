defmodule ToDoListApp.Repo.Migrations.UpdateBoardPermission2 do
  use Ecto.Migration

  def change do
    alter table(:board_permission) do
      modify :permission_type, :text, null: false
    end
  end
end

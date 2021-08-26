defmodule ToDoListApp.Repo.Migrations.UpdateList do
  use Ecto.Migration

  def change do
    alter table(:list) do
      add :creator_id, references(:users, column: :user_id, type: :uuid, on_delete: :delete_all)
      modify :board_id, :uuid, null: false
    end
  end
end

defmodule ToDoListApp.Repo.Migrations.UpdateTaskTable9 do
  use Ecto.Migration

  def change do
    alter table(:task) do
      modify :assigned_to_id, :uuid, null: true
    end
  end
end

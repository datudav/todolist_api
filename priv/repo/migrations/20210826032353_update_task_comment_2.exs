defmodule ToDoListApp.Repo.Migrations.UpdateTaskComment2 do
  use Ecto.Migration

  def change do
    alter table(:task_comment) do
      add :creator_id, references(:users, column: :user_id, type: :uuid, on_delete: :delete_all), null: false
    end
  end
end

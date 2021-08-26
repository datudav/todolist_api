defmodule ToDoListApp.Repo.Migrations.UpdateTaskComment do
  use Ecto.Migration

  def change do
    alter table(:task_comment) do
      modify :task_id, :uuid, null: false
    end
  end
end

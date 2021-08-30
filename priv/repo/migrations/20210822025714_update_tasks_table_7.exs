defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable7 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
    UPDATE tasks
    SET rank = extract(epoch from inserted_at);
    """)
  end
end

defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable3 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
    ALTER TABLE tasks DROP COLUMN id;
    """)
  end
end

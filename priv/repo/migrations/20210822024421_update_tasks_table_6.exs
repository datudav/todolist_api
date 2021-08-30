defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable6 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
    ALTER TABLE tasks ADD COLUMN rank decimal;
    """)
  end
end

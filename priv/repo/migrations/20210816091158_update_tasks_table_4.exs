defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable4 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    """)
  end
end

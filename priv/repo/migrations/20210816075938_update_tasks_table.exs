defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
      ALTER TABLE tasks
        ALTER COLUMN title TYPE text,
        ALTER COLUMN description TYPE text;
    """)
  end
end

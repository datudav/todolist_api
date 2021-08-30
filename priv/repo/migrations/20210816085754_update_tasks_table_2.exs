defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable2 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
      ALTER TABLE tasks DROP CONSTRAINT tasks_pkey;
    """)
  end
end

defmodule ToDoListApp.Repo.Migrations.UpdateTasksTable5 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
    ALTER TABLE tasks ADD COLUMN id uuid DEFAULT uuid_generate_v4();
    """)
  end
end

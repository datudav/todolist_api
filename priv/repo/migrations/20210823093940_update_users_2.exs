defmodule ToDoListApp.Repo.Migrations.UpdateUsers2 do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
        ALTER TABLE users ADD COLUMN is_active boolean NOT NULL;
      """)
  end
end

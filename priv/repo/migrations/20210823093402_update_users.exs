defmodule ToDoListApp.Repo.Migrations.UpdateUsers do
  use Ecto.Migration

  def change do
    ToDoListApp.Repo.query("""
        ALTER TABLE users DROP COLUMN " is_active";
      """)
  end
end

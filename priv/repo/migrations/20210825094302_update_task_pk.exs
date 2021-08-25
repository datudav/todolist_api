defmodule ToDoListApp.Repo.Migrations.UpdateTaskPK do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE task ADD CONSTRAINT task_pkey PRIMARY KEY (task_id)")
  end
end

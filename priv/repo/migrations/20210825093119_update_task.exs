defmodule ToDoListApp.Repo.Migrations.UpdateTask do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE tasks RENAME TO task")

    rename table(:task), :id, to: :task_id

    alter table(:task) do
      add :list_id, references(:list, column: :list_id, type: :uuid, on_delete: :delete_all)
    end
  end
end

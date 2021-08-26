defmodule ToDoListApp.Repo.Migrations.UpdateTaskIdCol do
  use Ecto.Migration

  def change do
    alter table(:task) do
      add :assigned_to_id, references(:users, column: :user_id, type: :uuid, on_delete: :delete_all), null: false
      modify :list_id, :uuid, null: false
    end
  end
end

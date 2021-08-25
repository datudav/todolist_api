defmodule ToDoListApp.Repo.Migrations.CreateTaskComment do
  use Ecto.Migration

  def change do
    create table(:task_comment, primary_key: false) do
      add :task_comment_id, :binary_id, primary_key: true, default: fragment("uuid_generate_v4()")
      add :comments, :text, null: false
      add :task_id, references(:task, column: :task_id, type: :uuid, on_delete: :delete_all)

      timestamps()
    end
  end
end
